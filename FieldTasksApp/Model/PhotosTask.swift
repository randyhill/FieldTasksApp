import Foundation

@objc(PhotosTask)
open class PhotosTask: _PhotosTask {
    override var editorId : String { get { return "PhotosTaskEditor"} }
    override var viewerId : String { get { return "PhotosTaskViewer"} }

//    override init(taskDict : [String : AnyObject]) {
//        super.init(taskDict: taskDict)
//        self.type = TaskType.Photos
//    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let typeString = dataDict["selections"] as? String {
            if typeString == "single" {
                self.isSingle = true
            } else if typeString == "multiple" {
                self.isSingle = false
            }
        }
    }

    override func initResults(results : [String: AnyObject]) {
       // self.result = PhotosResult(task: self, results: results)
        self.result = PhotosResult(task: self)
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["selections"] = (isSingle!.boolValue ? "single" : "multiple") as AnyObject
        return dict
    }

    override func taskDescriptionString() -> String {
        return isSingle!.boolValue ? "Single Photo" : "Multiple Photos"
    }
}
