//
//  NetworkOps.swift
//  FieldTasksApp
//
//  Created by CRH on 3/31/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

// MARK: Network Op  -------------------------------------------------------------------------------
class NetworkOp : Operation {

    // MARK: Inherited  ----------------------------------------------------------------------------
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
        FTPrint(s: "Starting net op: \(className(object: self))")
        if self.canceled() {
            return
        }
        bgTaskID = beginBackgroundUpdateTask()
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = true
        self.didChangeValue(forKey: "isExecuting")

        main()
    }

    // MARK: Custom  -----------------------------------------------------------------------------
    var isRunning = false
    var bgTaskID : UIBackgroundTaskIdentifier?

    func complete() {
        setCompleteFlags()
        FTPrint(s: "Completed net op: \(className(object: self))")
        endBackgroundUpdateTask(taskID: bgTaskID!)
    }

    func cancelIt() {
        self.cancel()
        if self.isRunning {
            endBackgroundUpdateTask(taskID: bgTaskID!)
        }
        setCompleteFlags()
    }

    private func setCompleteFlags() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = false
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
    }

    // Don't resubmit if we get canceled before completion
    func canceled() -> Bool {
        if self.isCancelled {
            FTPrint(s: "Canceled net op: \(className(object: self))")
            self.complete()
        }
        return self.isCancelled
    }

    // Success means reset our queue delay
    func success() {
        NetworkOpsMgr.shared.removeFromCoreDataList(netOp: self)
    }

    func asCoreData() -> NetQueueOp {
        return CoreDataMgr.createNetQueueOp(context: NetworkOpsMgr.shared.backgroundContext)
    }
}

// MARK: AWS Image Ops  -------------------------------------------------------------------------------

class AWSOp : NetworkOp {
    var fileName : String

    init(fileName: String) {
        self.fileName = fileName
    }

    // The main thing we want to stop if canceled is resubmitting new operations
    func retry(awsOp: AWSOp) {
        if !self.canceled() {
            NetworkOpsMgr.shared.retryAWSOp(awsOp: awsOp)
        }
    }

    var lastProgress : Float = 0.0
    func print(progress: Float) {
        if progress - lastProgress > 0.1 {
            lastProgress = progress
            FTPrint(s: self.fileName + ": \(progress)")
        }
    }

    override func success() {
        super.success()
        NetworkOpsMgr.shared.resetAWSRetryDelay()
    }
}

class ImageUploadOp : AWSOp {
    override func main() {
        FTPrint(s: "Start upload: \(self.fileName)")
        ServerMgr.shared.uploadImage(fileName:  self.fileName, progress: { progress in
            self.print(progress: progress)
        }, completion: { (filename, error ) in
            if !self.canceled() {
                if let error = error {
                    FTPrint(s: "Retry upload: \(self.fileName) - \(error)")
                    self.retry(awsOp: ImageUploadOp(fileName: self.fileName))
                } else {
                    FTPrint(s: "Finished upload: \(self.fileName)")
                    self.success()
                }
                self.complete()
            }

        })
    }

    override func asCoreData() -> NetQueueOp {
        let data = super.asCoreData()
        data.typeName = "ImageUploadOp"
        data.objectKey = fileName
        return data
    }
}

class ImageDownloadOp : AWSOp {
    var photosResult : PhotosResult
    var imageLoaded: (_ image: UIImage)->()
    var progress: (_ progress: Float)->()

    init(fileName : String, photosResult : PhotosResult, progress: @escaping (_ progress: Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
        self.photosResult = photosResult
        self.imageLoaded = imageLoaded
        self.progress = progress
        super.init(fileName: fileName)
    }

    override func main() {
        FTPrint(s: "Start download: \(self.fileName)")
        ServerMgr.shared.downloadImage(fileName: fileName, progress: progress, completion: { (image, errorString) in
            if !self.canceled() {
                if let image = image {
                    self.photosResult.set(photo: image, fileName: self.fileName)
                    self.imageLoaded(image)
                    self.success()
                    FTPrint(s: "Finished download: \(self.fileName)")
                } else {
                    FTPrint(s: "Retry download: \(self.fileName)")
                    self.retry(awsOp: ImageDownloadOp(fileName: self.fileName, photosResult: self.photosResult, progress: self.progress, imageLoaded: self.imageLoaded))
                }
                self.complete()
            }
        })
    }

    // We don't want to restart downloads at this point.
    override func success() {
        NetworkOpsMgr.shared.resetAWSRetryDelay()
    }

//    override func asCoreData() -> NetQueueOp {
//        let data = super.asCoreData()
//        data.typeName = "ImageDownloadOp"
//        data.objectKey = fileName
//        return data
//    }
}

// MARK: Server Ops  -------------------------------------------------------------------------------

class ServerOp : NetworkOp {
    func retry(serverOp: ServerOp) {
        if !self.canceled() {
            NetworkOpsMgr.shared.retryServerOp(serverOp: serverOp)
        }
    }

    // The main thing we want to stop if canceled is resubmitting new operations
    override func success() {
        super.success()
        NetworkOpsMgr.shared.resetServerRetryDelay()
    }
}

class FormSubmitOp : ServerOp {
    let form : Form

    init(form : Form) {
        self.form = form

        // Save with temp id that we can use to link to coredata net op, it will be replaced with serverId
        self.form.id = randomName(length: 12)
        CoreDataMgr.shared.saveOnMainThread()
    }

    override func main() {
        FTPrint(s: "Form submission starting")
        ServerMgr.shared.saveAsForm(form: form) { (result, error) in
            if error != nil {
                FTPrint(s: "Error submitting form: \(error)")
                self.retry(serverOp: FormSubmitOp(form: self.form))
            } else {
                //  update id
                if let formDict = result, let formId = formDict["_id"] as? String {
                    if let submissionString = formDict["submitted"] as? String {
                        // Call success so it removes from coredata ops list before temp ID is changed.
                        self.success()

                        // Now update with server ID/submitted time stamp, and save, was created on main thread
                        self.form.id = formId
                        self.form.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
                        CoreDataMgr.shared.saveOnMainThread()
                        FTPrint(s: "Form submitted successfully")
                    } else {
                        FTPrint(s: "couldn't get form submission time stamp")
                        self.retry(serverOp: FormSubmitOp(form: self.form))
                    }
                } else {
                    FTPrint(s: "Couldn't get updated form id")
                    self.retry(serverOp: FormSubmitOp(form: self.form))
                }
            }
            self.complete()
        }
    }

    override func asCoreData() -> NetQueueOp {
        let data = super.asCoreData()
        data.typeName = "FormSubmitOp"
        data.objectKey = form.id
        return data
    }
}
