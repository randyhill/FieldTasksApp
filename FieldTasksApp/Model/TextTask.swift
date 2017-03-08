import Foundation

@objc(TextTask)
open class TextTask: _TextTask {
    override var editorId : String { get { return "TextTaskEditor"} }
    override var viewerId : String { get { return "TextTaskViewer"} }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        //  self.taskDescription = TextTaskDescription(dataDict: dataDict)
        if let limitBool = dataDict["range"] as? String {
            self.isUnlimited = (limitBool == "unlimited") ? true : false
        }
        if let maxVal = dataDict["max"] as? Int {
            self.max = maxVal as NSNumber?
        }
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
