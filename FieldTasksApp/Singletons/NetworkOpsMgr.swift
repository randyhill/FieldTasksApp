//
//  NetworkOpsMgr
//  FieldTasksApp
//  Created by CRH on 3/25/17.
//  Copyright © 2017 CRH. All rights reserved.
/*
    This manager allows us to
    - Run network operations in the background so that the UI can run unimpeded
    - Resubmit network operations if they fail
    - Continue network operations for available time when app goes to background
    - Save and retry network operations if app runs out of background time or is quit before they finish
 
    Each network operation needs to follow standard NSOperation rules for starting/completing, and checking for cancelation
    - Since we are asynchornous background operations, execution starts in start() in parent class, it calls main() for subclasses to provide operation code
    - The parent classes will create every network operation as a background operation so that they continue to run if app goes to background.
    - This means start() and complete() have to be called to balance backgroundOps calls.
    - isCanceled will be set to true for any ops that haven't started yet when app goes to background.
    - isCanceled is automatically checked at start() and for any attempt to retry(), it doesn't need to be called elsewhere except for lengthy operations.
    - Ops need to implement save()/restore() so they can be saved and re-created later if canceled from queue before being executed
 */

import UIKit
import CoreData

// MARK: Network Op  -------------------------------------------------------------------------------
class NetworkOp : Operation {
    // MARK: Inherited  -------------------------------------------------------------------------------
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

    // MARK: NetworkOp  -------------------------------------------------------------------------------
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
    }

 //   func save() -> NetOpData {
//
//    }
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
        NetworkOpsMgr.shared.resetAWSRetryDelay()
    }

//    override func save() -> NetOpData {
//        //CoreDataMgr.createNetOp()
//    }
}

class ImageUploadOp : AWSOp {
    var map : PhotoFileListMap

    init(map : PhotoFileListMap) {
        self.map = map
        super.init(fileName: map.fileName!)
   }

    override func main() {
        FTPrint(s: "Start upload: \(self.fileName)")
        ServerMgr.shared.uploadImage(fileName:  map.fileName!, progress: { progress in
            self.print(progress: progress)
        }, completion: { (filename, error ) in
            if !self.canceled() {
                if let error = error {
                    FTPrint(s: "Retry upload: \(self.fileName) - \(error)")
                    self.retry(awsOp: ImageUploadOp(map: self.map))
                } else {
                    FTPrint(s: "Finished upload: \(self.fileName)")
                }
                self.complete()
            }

        })
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
        ServerMgr.shared.downloadFile(imageFileName: fileName, progress: progress, completion: { (image, errorString) in
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
        NetworkOpsMgr.shared.resetServerRetryDelay()
    }
}

class FormSubmitOp : ServerOp {
    let form : Form

    init(form : Form) {
        self.form = form
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
                    self.form.id = formId
                    if let submissionString = formDict["submitted"] as? String {
                        // Form was created on main thread
                        self.form.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
                        CoreDataMgr.shared.saveOnMainThread()
                        self.success()
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
}

// MARK: NetworkOpsMgr  -------------------------------------------------------------------------------
let cNetOpRetryStartIncrement : TimeInterval = 5.0

class NetworkOpsMgr {
    static let shared = NetworkOpsMgr()

    lazy var serverQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.fieldtasks.serverQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var awsQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.fieldtasks.awsQueue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()

    var acceptNewOps = true

    let backgroundContext = CoreDataMgr.shared.getNewContext()

    func saveCoreData(save: @escaping (_ context: NSManagedObjectContext)->()) {
        backgroundContext.perform({
            save(self.backgroundContext)
            CoreDataMgr.shared.saveInContext(context: self.backgroundContext)
        })
    }

    // MARK: Retry  -------------------------------------------------------------------------------
    // Can't share retry intervals between queues, what if one server is temporarily down but other still accessible?
    private var _awsInterval : TimeInterval = cNetOpRetryStartIncrement
    private var _serverInterval : TimeInterval = cNetOpRetryStartIncrement
    private var serverInterval : TimeInterval {
        get {
            FTPrint(s:"incrementing server increment from \(_serverInterval)")
            _serverInterval *= 2
            FTPrint(s:"to \(_serverInterval)")
            return _serverInterval
        }
    }
    private var awsInterval : TimeInterval {
        get {
            FTPrint(s:"incrementing server increment from \(_awsInterval)")
            _awsInterval *= 2
            FTPrint(s:"to \(_awsInterval)")
            return _awsInterval
        }
    }

    fileprivate func resetServerRetryDelay() {
        FTPrint(s:"Reset server increment")
        _serverInterval = cNetOpRetryStartIncrement
    }

    fileprivate func resetAWSRetryDelay() {
        FTPrint(s:"Reset AWS increment")
        _awsInterval = cNetOpRetryStartIncrement
    }

    fileprivate func retryServerOp(serverOp : ServerOp) {
        if !acceptNewOps {
            FTPrint(s: "Can't retry: \(className(object: serverOp)), queue stopped")
        } else {
            FTPrint(s: "Retry net op: \(serverInterval) seconds")
            let dispatchTime: DispatchTime = DispatchTime.now() + serverInterval
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                FTPrint(s: "Checking for server net access")
                if isConnectedToNetwork() {
                    FTPrint(s: "Server has net access")
                    self.addServerOp(serverOp: serverOp)
                } else {
                    self.retryServerOp(serverOp: serverOp)
                }
            }
        }
    }

    fileprivate func retryAWSOp(awsOp : AWSOp) {
        if !acceptNewOps {
            FTPrint(s: "Can't retry: \(awsOp.fileName), queue stopped")
        } else {
            FTPrint(s: "Retry aws op: \(awsInterval) seconds")
            let dispatchTime: DispatchTime = DispatchTime.now() + awsInterval
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                FTPrint(s: "Checking AWS for net access")
                if isConnectedToNetwork() {
                    FTPrint(s: "AWS has net access")
                    self.addAWSOp(awsOp: awsOp)
                } else {
                    self.retryAWSOp(awsOp: awsOp)
                }
            }
        }
    }

    func restartOperations() {
        acceptNewOps = true
    }

    func stopOperations() {
        self.cancelQueueOperations(queue: self.awsQueue)
        self.cancelQueueOperations(queue: self.serverQueue)
        acceptNewOps = false
   }

    // Cancel all operations in queue that aren't running yet
    private func cancelQueueOperations(queue: OperationQueue) {
        for op in queue.operations {
            if !op.isExecuting {
                if let netOp = op as? NetworkOp {
                    netOp.cancelIt()
                }
            }
        }
    }

    // MARK: Add/Submit ops  -------------------------------------------------------------------------------
    fileprivate func addServerOp(serverOp : ServerOp) {
        FTPrint(s: "Adding \(className(object: serverOp)) to Server queue")
        FTPrint(s: "Server Queue count: \(serverQueue.operationCount)")
        serverQueue.addOperation(serverOp)
    }

    fileprivate func addAWSOp(awsOp : AWSOp) {
        FTPrint(s: "Adding \(className(object: awsOp)) to AWS queue")
        FTPrint(s: "AWS Queue count: \(awsQueue.operationCount)")
        for op in awsQueue.operations {
            if let queueOp = op as? AWSOp {
                if awsOp.fileName == queueOp.fileName {
                    FTPrint(s:"Tried to add dupe to AWS queue, ignored")
                    return
                }
            }
        }
        awsQueue.addOperation(awsOp)
    }

    func submitForm(form : Form) {
        // Use location coords from initial submission point
        if let coordinates = LocationsMgr.shared.currentCoordinates() {
            form.latitude = coordinates.latitude as NSNumber?
            form.longitude = coordinates.longitude as NSNumber?
        }
        self.addServerOp(serverOp: FormSubmitOp(form: form))

        // Upload each image seperately
        let photosMap = PhotoFileList(tasks: form.tasks).mapOfAllImages()
        for photoMap in photosMap {
            self.addAWSOp(awsOp: ImageUploadOp(map: photoMap))
        }
    }

    func downloadImages(fileNames : [String], photosResult : PhotosResult, progress: @escaping (_ progress : Float)->(), imageLoaded: @escaping (_ image: UIImage)->()) {
        var progressCounts = [String : Float]()
        for fileName in fileNames {
            progressCounts[fileName] = 0.0
            let downloadOp = ImageDownloadOp(fileName: fileName, photosResult: photosResult, progress: { (progressVal) in
                // intercept each individual download progress and calculate group progress. We weight each file the same, would be more
                // accurate if we adjusted for file sizes
                progressCounts[fileName] = progressVal
                let total = progressCounts.reduce(0, { (sum, element: (key: String, value: Float)) -> Float in
                    return sum + element.value
                })
                let partialProgress = total/Float(progressCounts.count)
                progress(partialProgress)
            }, imageLoaded: imageLoaded)
            self.addAWSOp(awsOp: downloadOp)
        }
    }
}
