//
//  NetOpsQueueMgr
//  FieldTasksApp
//
//  Created by CRH on 3/25/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

class NetworkOp : Operation {
    var isRunning = false

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
        print( "Starting net op")
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
        print( "Completed net op")
    }

    // Always resubmit if we get canceled before completion
    func checkCancel() -> Bool {
        if self.isCancelled {
            print( "Canceled net op")
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
    let photoFileList : PhotoFileList
    let form : Form

    init(form : Form, photoFileList : PhotoFileList) {
        self.form = form
        self.photoFileList = photoFileList
    }

    override func main() {
        print( "Photos upload starting")
        if self.checkCancel() {
            return
        }
         ServerMgr.shared.uploadImagesWithoutUI(photoFileList: photoFileList) { (list, err) in
            if let _ = list {
                // Form should have been updated with file names, write to CoreData
                print( "Photos uploaded successfully")
                let backgroundContext = CoreDataMgr.shared.getNewContext()
                backgroundContext.perform({
                    CoreDataMgr.shared.saveInContext(context: backgroundContext)
                })

                // Now submit form
                if !self.isCancelled {
                    NetOpsQueueMgr.shared.submitForm(form: self.form)
                 }
            } else {
                print("Photos upload failed because of: \(err!)")
                self.retry()
            }
            self.complete()
        }
    }

    override func retry() {
        NetOpsQueueMgr.shared.retryWithDelay(op: ImagesUploadOp(form: self.form, photoFileList: self.photoFileList))
    }
}

class FormSubmitOp : NetworkOp {
    let form : Form

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
        NetOpsQueueMgr.shared.retryWithDelay(op: FormSubmitOp(form: self.form))
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

    fileprivate func retryWithDelay(op : Operation) {
        print( "Retry net op: \(currentRetryInterval) seconds")
        let dispatchTime: DispatchTime = DispatchTime.now() + currentRetryInterval
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            print( "Checking for net access")
            if isConnectedToNetwork() {
                print( "We have net access")
                self.opsQueue.addOperation(op)
            } else {
                self.retryWithDelay(op: op)
            }
        }
    }

    fileprivate func submitForm(form: Form) {
        let formSubOp = FormSubmitOp(form: form)
        print( "Adding submit form to queue")
        opsQueue.addOperation(formSubOp)
    }

    fileprivate func uploadImages(form : Form, photoFileList : PhotoFileList) {
        let imagesOp = ImagesUploadOp(form: form, photoFileList: photoFileList)
        print( "Adding upload images to queue")
        print( "Opsqueue count: \(opsQueue.operationCount)")
        opsQueue.addOperation(imagesOp)
    }

    func submitFormWithPhotos(form : Form) {
        // Use location coords from initial submission point
        if let coordinates = LocationsMgr.shared.currentCoordinates() {
            form.latitude = coordinates.latitude as NSNumber?
            form.longitude = coordinates.longitude as NSNumber?
        }
        let photosList = PhotoFileList(tasks: form.tasks , buildWithImages: true)
        if photosList.count == 0 {
            self.submitForm(form: form)
        } else {
            self.uploadImages(form: form, photoFileList: photosList)
        }
    }
}
