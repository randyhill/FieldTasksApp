import Foundation

@objc(NumberResult)
open class NumberResult: _NumberResult {
    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)

        if let valueResult = results["number"] as? Double {
            value = valueResult as NSNumber?
        }
    }

    override func save(newText : String) {
       completed_private = false
        if let newValue = Double(newText) {
            value = newValue as NSNumber?
            if let numberTask = task as? NumberTask, let value = value {
                if numberTask.isUnlimited!.boolValue || (value.doubleValue >= numberTask.min!.doubleValue && value.doubleValue <= numberTask.max!.doubleValue) {
                   completed_private = true
                }
            }
        }
    }
    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()

        if let numberValue = value {
            dict["number"] = numberValue as AnyObject?
        }
        return dict
    }

    override func resultString() -> String {
        if let numberTask =  task as? NumberTask {
            if let numberValue = value {
                if numberTask.isDecimal!.boolValue {
                    return "\(numberValue.doubleValue)"
                } else {
                    return "\(numberValue.intValue)"
                }
            }
        }
        return ""
    }
}
