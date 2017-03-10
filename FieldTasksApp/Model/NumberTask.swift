import Foundation

@objc(NumberTask)
open class NumberTask: _NumberTask {
    override var editorId : String { get { return "NumberTaskEditor"} }
    override var viewerId : String { get { return "NumberTaskViewer"} }

    var minString : String {
        get {
            if isDecimal!.boolValue {
                return "\(min!)"
            } else {
                let intMin = min!
                return "\(intMin)"
            }
        }
    }
    var maxString : String {
        get {
            if isDecimal!.boolValue {
                return "\(max!)"
            } else {
                return "\(max!)"
            }
        }
    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        // self.taskDescription = NumberTaskDescription(dataDict: dataDict)
        if let isDecimal = dataDict["isDecimal"] as? Bool {
            self.isDecimal = isDecimal as NSNumber?
        }
        if let limitBool = dataDict["range"] as? String {
            self.isUnlimited = (limitBool == "unlimited") as NSNumber
        }
        if let minVal = dataDict["min"] as? Double {
            self.min = minVal as NSNumber?
        }
        if let maxVal = dataDict["max"] as? Double {
            self.max = maxVal as NSNumber?
        }
    }

    override func resultTypeString() -> String {
        return "NumberResult"
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["isDecimal"] = isDecimal as AnyObject?
        dict["range"] = (isUnlimited!.boolValue ? "unlimited" : "limited") as AnyObject
        dict["min"] = min as AnyObject?
        dict["max"] = max as AnyObject?
        return dict
    }

    override func taskDescriptionString() -> String {
        return isUnlimited!.boolValue ? "Unlimited range" : "Minimum: \(self.minString)   Maximum: \(self.maxString)"
    }
}
