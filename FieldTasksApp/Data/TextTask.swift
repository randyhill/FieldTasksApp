//
//  TextTask.swift
//  FieldTasksApp
//
//  Created by CRH on 2/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

// MARK: TextTask Class -------------------------------------------------------------------------------
class TextTask : Task {
    var isUnlimited = true  // defaults to no range limits
    var max = 0

//    override init() {
//        super.init()
//        name = "Text Task"
//    }

    override init(taskDict : [String : AnyObject]) {
        super.init(taskDict: taskDict)
        self.type = TaskType.Text
    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        //  self.taskDescription = TextTaskDescription(dataDict: dataDict)
        if let limitBool = dataDict["range"] as? String {
            self.isUnlimited = (limitBool == "unlimited")
        }
        if let maxVal = dataDict["max"] as? Int {
            self.max = maxVal
        }
    }

    override func initResults(results : [String: AnyObject]) {
        self.result = TextResult(task: self, results: results)
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["range"] = (isUnlimited ? "unlimited" : "limited") as AnyObject
        dict["max"] = max as AnyObject?
        return dict
    }
}

// MARK: TextResult Class -------------------------------------------------------------------------------
class TextResult : TaskResult {
    var text = ""

    override init(task : Task, results: [String : AnyObject]) {
        super.init(task: task, results: results)

        if let resultText = results["text"] as? String {
            text = resultText
        }
    }

    override func save(newText : String) {
        _completed = false
        text = newText
        if text.characters.count > 0 {
            _completed = true
        }
    }
    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["text"] = text as AnyObject?
        return dict
    }

    override func description() -> String {
        return text
    }
}
