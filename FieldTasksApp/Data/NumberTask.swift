//
//  NumberTask.swift
//  FieldTasksApp
//
//  Created by CRH on 2/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

// MARK: NumberTask Class -------------------------------------------------------------------------------
class NumberTask : Task {
    var isDecimal = false
    var isUnlimited = true  // defaults to no range limits
    var min = 0.0            // We don't know if min/max types should be float or int yet
    var max = 0.0
    override var editorId : String { get { return "NumberTaskEditor"} }
    override var viewerId : String { get { return "NumberTaskViewer"} }

    var minString : String {
        get {
            if isDecimal {
                return "\(min)"
            } else {
                return "\(min.toInt())"
            }
        }
    }
    var maxString : String {
        get {
            if isDecimal {
                return "\(max)"
            } else {
                return "\(max.toInt())"
            }
        }
    }

    override init(taskDict : [String : AnyObject]) {
        super.init(taskDict: taskDict)
        self.type = TaskType.Number
    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        // self.taskDescription = NumberTaskDescription(dataDict: dataDict)
        if let isDecimal = dataDict["isDecimal"] as? Bool {
            self.isDecimal = isDecimal
        }
        if let limitBool = dataDict["range"] as? String {
            self.isUnlimited = (limitBool == "unlimited")
        }
        if let minVal = dataDict["min"] as? Double {
            self.min = minVal
        }
        if let maxVal = dataDict["max"] as? Double {
            self.max = maxVal
        }
    }

    override func initResults(results : [String: AnyObject]) {
        self.result = NumberResult(task: self, results: results)
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["isDecimal"] = isDecimal as AnyObject?
        dict["range"] = (isUnlimited ? "unlimited" : "limited") as AnyObject
        dict["min"] = min as AnyObject?
        dict["max"] = max as AnyObject?
        return dict
    }

    override func taskDescriptionString() -> String {
        return isUnlimited ? "Unlimited range" : "Minimum:\(min) Maximum: \(max)"
    }
}

// MARK: NumberResult Class -------------------------------------------------------------------------------
class NumberResult : TaskResult {
    var value : Double?

    override init(task : Task, results: [String : AnyObject]) {
        super.init(task: task, results: results)

        if let valueResult = results["number"] as? Double {
            value = valueResult
        }
    }

    override func save(newText : String) {
        _completed = false
        if let newValue = Double(newText) {
            value = newValue
            if let numberTask = task as? NumberTask, let value = value {
                if numberTask.isUnlimited || (value >= numberTask.min && value <= numberTask.max) {
                    _completed = true
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

    override func description() -> String {
        if let numberTask =  task as? NumberTask {
            if let numberValue = value {
                if numberTask.isDecimal {
                    return "\(numberValue)"
                } else {
                    return "\(numberValue.toInt())"
                }
            }
        }
        return ""
    }
}
