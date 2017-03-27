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
    }

    // Always resubmit if we get canceled before completion
    func checkCancel() -> Bool {
        if self.isCancelled {
            NetOpsQueueMgr.shared.retry(op: self)
            self.complete()
        }
        return self.isCancelled
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
        if self.checkCancel() {
            return
        }
        FTMessage(message: "Photos upload starting")
        ServerMgr.shared.uploadImagesWithoutUI(photoFileList: photoFileList) { (list, err) in
            if let _ = list {
                // Form should have been updated with file names, write to CoreData
                FTMessage(message: "Photos uploaded successfully")
                let backgroundContext = CoreDataMgr.shared.getNewContext()
                backgroundContext.perform({
                    CoreDataMgr.shared.saveInContext(context: backgroundContext)
                })

                // Now submit form
                if !self.isCancelled {
                    NetOpsQueueMgr.shared.submitForm(form: self.form)
                 }
            } else {
                FTMessage(message:"Photos upload failed because of: \(err!)")
                NetOpsQueueMgr.shared.retry(op: self)
            }
            self.complete()
        }
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
        FTMessage(message: "Form submission starting")
        ServerMgr.shared.saveAsForm(form: form) { (result, error) in
            if error != nil {
                FTMessage(message: "Error submitting form: \(error)")
                NetOpsQueueMgr.shared.retry(op: self)
            } else {
                //  update id
                if let formDict = result, let formId = formDict["_id"] as? String {
                    self.form.id = formId
                    if let submissionString = formDict["submitted"] as? String {
                        self.form.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
                        FTMessage(message: "Form submitted successfully")
                        let backgroundContext = CoreDataMgr.shared.getNewContext()
                        backgroundContext.perform({
                            CoreDataMgr.shared.saveInContext(context: backgroundContext)
                        })
                    } else {
                        FTMessage(message: "couldn't get form submission time stamp")
                        NetOpsQueueMgr.shared.retry(op: self)
                    }
                } else {
                    FTMessage(message: "couldn't update form id")
                    NetOpsQueueMgr.shared.retry(op: self)
                }
            }
        }
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

    private var _retryInterval : TimeInterval = 0
    var currentRetryInterval : TimeInterval {
        get {
            _retryInterval += retryIncrement
            return _retryInterval
        }
    }

    fileprivate func resetRetryIncrement() {
        _retryInterval = 0
    }

    fileprivate func retry(op : Operation) {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(currentRetryInterval * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            if isConnectedToNetwork() {
                self.opsQueue.addOperation(op)
                self.resetRetryIncrement()
            } else {
                self.retry(op: op)
            }
        }
    }

    fileprivate func submitForm(form: Form) {
        let formSubOp = FormSubmitOp(form: form)
        FTMessage(message: "Adding submit form to queue")
        opsQueue.addOperation(formSubOp)
    }

    fileprivate func uploadImages(form : Form, photoFileList : PhotoFileList) {
        let imagesOp = ImagesUploadOp(form: form, photoFileList: photoFileList)
        FTMessage(message: "Adding upload images to queue")
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
