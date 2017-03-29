//
//  NetOpsQueueMgr
//  FieldTasksApp
//
//  Created by CRH on 3/25/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class NetworkOp : Operation {
    var isRunning = false
    var className : String {
        get {
            return "NetworkOp"
        }
    }

    override var isAsynchronous: Bool {
        get {
            return true
        }
    }

    override var isConcurrent: Bool {
        get {
            return true
        }
    }

    override var isExecuting: Bool {
        get {
            return isRunning
        }
    }

    override var isFinished: Bool {
        get {
            return !isRunning
        }
    }

    override func start() {
        print( "Starting net op: \(self.className)")
        if self.checkCancel() {
            return
        }
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = true
        self.didChangeValue(forKey: "isExecuting")

        main()
    }

    func complete() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = false
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
        print( "Completed net op: \(self.className)")
    }

    // Always resubmit if we get canceled before completion
    func checkCancel() -> Bool {
        if self.isCancelled {
            print( "Canceled net op: \(self.className)")
            self.retry()
            self.complete()
        }
        return self.isCancelled
    }

    func retry() {
        // Create a new NetworkOp to match and resubmit since we can't reuse existing.
    }

    func success() {
        // Success means reset delay
        NetOpsQueueMgr.shared.resetRetryIncrement()
    }
}

class ImagesUploadOp : NetworkOp {
    var mapList : [PhotoFileListMap]
    let form : Form
    override var className : String {
        get {
            return "ImagesUploadOp"
        }
    }

    init(form : Form, photoFileList : PhotoFileList) {
        self.form = form
        self.mapList = photoFileList.mapOfAllImages()
    }

    init(form : Form, mapList : [PhotoFileListMap]) {
        self.form = form
        self.mapList = mapList
    }

    override func main() {
        print( "Photos upload starting")
        if self.checkCancel() {
            return
        }

        // First write image to disk and create random name for it
        let map = mapList.remove(at: 0)
        ServerMgr.shared.uploadImage(fileName:  map.fileName!, progress: { progress in
            FTMessage(message: "Progress: \(progress)")
        }, completion: { (filename, error ) in
            if let error = error {
                FTMessage(message: "Failed to upload file: \(map.fileName!) - " + error)
                self.retry()
            } else {
                FTMessage(message: "Uploaded file: \(map.fileName!)")
                if !self.isCancelled {
                    if self.mapList.count == 0 {
                        let backgroundContext = CoreDataMgr.shared.getNewContext()
                        backgroundContext.perform({
                            CoreDataMgr.shared.saveInContext(context: backgroundContext)
                        })
                        NetOpsQueueMgr.shared.submitForm(form: self.form)
                    } else {
                        NetOpsQueueMgr.shared.submitOp(netOp: ImagesUploadOp(form: self.form, mapList: self.mapList))
                    }
                }
            }
            self.complete()
        })
    }

    override func retry() {
        NetOpsQueueMgr.shared.retryOpWithDelay(op: ImagesUploadOp(form: self.form, mapList: self.mapList))
    }
}

class ImageDownloadOp : NetworkOp {
    var fileName : String
    var photosResult : PhotosResult
    var imageLoaded: (_ image: UIImage)->()
    var progress: (_ progress: Float)->()

    init(fileName : String, photosResult : PhotosResult, progress: @escaping (_ progress: Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
        self.fileName = fileName
        self.photosResult = photosResult
        self.imageLoaded = imageLoaded
        self.progress = progress
    }

    override func main() {
        ServerMgr.shared.downloadFile(imageFileName: fileName, progress: progress, completion: { (image, errorString) in
            if let image = image {
                self.photosResult.set(photo: image, fileName: self.fileName)
                self.imageLoaded(image)
            } else {
                self.retry()
            }
            self.complete()
        })
    }
    override func retry() {
        NetOpsQueueMgr.shared.retryOpWithDelay(op: ImageDownloadOp(fileName: fileName, photosResult: photosResult, progress: progress, imageLoaded: imageLoaded))
    }
}

class FormSubmitOp : NetworkOp {
    let form : Form
    override var className : String {
        get {
            return "FormSubmitOp"
        }
    }
    init(form : Form) {
        self.form = form
    }

    override func main() {
        if self.checkCancel() {
            return
        }
        print( "Form submission starting")
        ServerMgr.shared.saveAsForm(form: form) { (result, error) in
            if error != nil {
                print( "Error submitting form: \(error)")
                self.retry()
            } else {
                //  update id
                if let formDict = result, let formId = formDict["_id"] as? String {
                    self.form.id = formId
                    if let submissionString = formDict["submitted"] as? String {
                        self.form.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
                        print( "Form submitted successfully")
                        let backgroundContext = CoreDataMgr.shared.getNewContext()
                        backgroundContext.perform({
                            CoreDataMgr.shared.saveInContext(context: backgroundContext)
                            self.success()
                        })
                    } else {
                        print( "couldn't get form submission time stamp")
                        self.retry()
                    }
                } else {
                    print( "couldn't update form id")
                    self.retry()
                }
            }
            self.complete()
        }
    }

    override func retry() {
        NetOpsQueueMgr.shared.retryOpWithDelay(op: FormSubmitOp(form: self.form))
    }
}

// MARK: NetOpsQueueMgr  -------------------------------------------------------------------------------
let retryIncrement : TimeInterval = 15.0

class NetOpsQueueMgr {
    static let shared = NetOpsQueueMgr()

    lazy var opsQueue :OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.fieldtasks.netopsqueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var _retryInterval : TimeInterval = retryIncrement
    var currentRetryInterval : TimeInterval {
        get {
            print("incrementing retry increment from \(_retryInterval)")
            _retryInterval *= 2
            print("to \(_retryInterval)")
            return _retryInterval
        }
    }

    fileprivate func resetRetryIncrement() {
        print("Reset retry increment")
        _retryInterval = 0
    }

    fileprivate func retryOpWithDelay(op : Operation) {
        print( "Retry net op: \(currentRetryInterval) seconds")
        let dispatchTime: DispatchTime = DispatchTime.now() + currentRetryInterval
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            print( "Checking for net access")
            if isConnectedToNetwork() {
                print( "We have net access")
                self.opsQueue.addOperation(op)
            } else {
                self.retryOpWithDelay(op: op)
            }
        }
    }

    func submitOp(netOp : NetworkOp) {
        print( "Adding \(netOp.className) to queue")
        print( "Opsqueue count: \(opsQueue.operationCount)")
        opsQueue.addOperation(netOp)
    }

    fileprivate func submitForm(form: Form) {
        let formSubOp = FormSubmitOp(form: form)
        self.submitOp(netOp: formSubOp)
    }

    fileprivate func uploadImages(form : Form, photoFileList: PhotoFileList) {
        let imagesOp = ImagesUploadOp(form: form, photoFileList: photoFileList)
        self.submitOp(netOp: imagesOp)
    }

    func submitFormWithPhotos(form : Form) {
        // Use location coords from initial submission point
        if let coordinates = LocationsMgr.shared.currentCoordinates() {
            form.latitude = coordinates.latitude as NSNumber?
            form.longitude = coordinates.longitude as NSNumber?
        }
        let photosList = PhotoFileList(tasks: form.tasks)
        if photosList.count == 0 {
            self.submitForm(form: form)
        } else {
            self.uploadImages(form: form, photoFileList: photosList)
        }
    }

    func downloadImage(fileName : String, photosResult : PhotosResult, progress: @escaping (_ progress : Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
        for op in opsQueue.operations {
            if let downloadOp = op as? ImageDownloadOp {
                if downloadOp.fileName == fileName {
                    print("tried to submit dupe download")
                    return
                }
            }
        }
        let downloadOp = ImageDownloadOp(fileName: fileName, photosResult: photosResult, progress: progress, imageLoaded: imageLoaded)
        self.submitOp(netOp: downloadOp)
    }
}
