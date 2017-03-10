import Foundation

@objc(TextTask)
open class TextTask: _TextTask {
    override var editorId : String { get { return "TextTaskEditor"} }
    override var viewerId : String { get { return "TextTaskViewer"} }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        //  self.taskDescription = TextTaskDescription(dataDict: dataDict)
        self.isUnlimited = dataDict["range"] as? NSNumber  ?? false
        self.max = dataDict["max"] as? NSNumber  ?? 0
    }

    override func resultTypeString() -> String {
        return "TextResult"
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["range"] = ((isUnlimited! == 1) ? "unlimited" : "limited") as AnyObject
        dict["max"] = max as AnyObject?
        return dict
    }
    
    override func taskDescriptionString() -> String {
        return (isUnlimited! == 1) ? "Unlimited length" : "Maximum length: \(max)"
    }
}
