import Foundation

@objc(PhotosTask)
open class PhotosTask: _PhotosTask {
    override var editorId : String { get { return "PhotosTaskEditor"} }
    override var viewerId : String { get { return "PhotosTaskViewer"} }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let typeString = dataDict["selections"] as? String {
            if typeString == "single" {
                self.isSingle = true
            } else if typeString == "multiple" {
                self.isSingle = false
            }
        }
    }

    override func resultTypeString() -> String {
        return "PhotosResult"
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
