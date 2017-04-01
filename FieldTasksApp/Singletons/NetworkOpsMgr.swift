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


// MARK: NetworkOpsMgr  -------------------------------------------------------------------------------
let cNetOpRetryStartIncrement : TimeInterval = 5.0

class NetworkOpsMgr {
    static let shared = NetworkOpsMgr()

    lazy var serverQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.fieldtasks.serverQueue"
        queue.maxConcurrentOperationCount = 2
        return queue
    }()

    lazy var awsQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.fieldtasks.awsQueue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()

    var acceptNewOps = true

    init() {
        DispatchQueue.global(qos: .background).async {
            self.loadCoreDataList()
        }
    }

    // MARK: CoreData  -------------------------------------------------------------------------------
    // Store descriptors of active operations persistently so we can restart them if quit
    let backgroundContext = CoreDataMgr.shared.getNewContext()
    var coreArray : NetOpsQueue?

    func saveCoreData(save: @escaping (_ context: NSManagedObjectContext)->()) {
        backgroundContext.perform({
            save(self.backgroundContext)
            CoreDataMgr.saveInContext(context: self.backgroundContext)
        })
    }

    private func loadCoreDataList() {
        coreArray = CoreDataMgr.getNetOpList(context: self.backgroundContext)
        FTPrint(s: coreArray!.describe())

        if let relationships = coreArray?.relationshipSet() {
            for relation in relationships {
                if let descriptor = relation as? NetQueueOp {
                    let networkOp = createOpFromCoreDataDescriptor(descriptor: descriptor)
                    if let awsOp = networkOp as? AWSOp {
                        self.addAWSOp(awsOp: awsOp)
                    } else if let serverOp = networkOp as? ServerOp {
                        self.addServerOp(serverOp: serverOp)
                    }
                }
            }
        }
    }

    func createOpFromCoreDataDescriptor(descriptor: NetQueueOp) -> NetworkOp? {
        var networkOp : NetworkOp?
        switch descriptor.typeName! {
        case className(object: ImageUploadOp.self):
            networkOp = ImageUploadOp(fileName: descriptor.objectKey!)
        case className(object: FormSubmitOp.self):
            if let form = CoreDataMgr.fetchById(context: self.backgroundContext, entityName: Form.entityName(), objectId: descriptor.objectKey!) as? Form {
                networkOp = FormSubmitOp(form: form)
            }
        default:
            FTErrorMessage(error: "Could not recreate network op: \(descriptor.typeName)")
        }
        return networkOp
    }

    func addToCoreDataList(netOp: NetworkOp) {
        let opDescription = netOp.asCoreData()

        // Don't add duplicates
        for existingOp in coreArray!.opsDataArray() {
            if existingOp.compare(other: opDescription) {
                return
            }
        }
        FTPrint(s: "Added Core Data Descriptor: \(opDescription.describe())")
        coreArray?.addRelationshipObject(opDescription)
        CoreDataMgr.saveInContext(context: self.backgroundContext)
    }


    func removeFromCoreDataList(netOp: NetworkOp) {
        if let opDescriptons = coreArray?.opsDataArray(){
            let opDescription = netOp.asCoreData()
            for descriptor in opDescriptons {
                if descriptor.typeName == opDescription.typeName && descriptor.objectKey == opDescription.objectKey {
                    coreArray?.removeRelationshipObject(descriptor)
                    FTPrint(s: "Removed Core Data Descriptor: \(descriptor.describe())")
                    FTPrint(s: coreArray!.describe())
                    CoreDataMgr.saveInContext(context: self.backgroundContext)
                    break;
                }
            }
        }
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

    func resetServerRetryDelay() {
        FTPrint(s:"Reset server increment")
        _serverInterval = cNetOpRetryStartIncrement
    }

    func resetAWSRetryDelay() {
        FTPrint(s:"Reset AWS increment")
        _awsInterval = cNetOpRetryStartIncrement
    }

    func retryServerOp(serverOp : ServerOp) {
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

    func retryAWSOp(awsOp : AWSOp) {
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
        addToCoreDataList(netOp: serverOp)
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
        // Save to core data before we add to queue
        addToCoreDataList(netOp: awsOp)
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
            self.addAWSOp(awsOp: ImageUploadOp(fileName: photoMap.fileName!))
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
