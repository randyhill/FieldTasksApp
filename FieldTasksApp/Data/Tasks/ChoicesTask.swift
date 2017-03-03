//
//  ChoicesTask.swift
//  FieldTasksApp
//
//  Created by CRH on 2/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

// MARK: ChoicesTask Class -------------------------------------------------------------------------------
class ChoicesTask : Task {
    var isRadio = true
    var titles = [String]()
    override var editorId : String { get { return "ChoicesTaskEditor"} }
    override var viewerId : String { get { return "ChoicesTaskViewer"} }

    override init(taskDict : [String : AnyObject]) {
        super.init(taskDict: taskDict)
        self.type = TaskType.Choices
    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let isRadio = dataDict["selections"] as? String {
            self.isRadio = (isRadio == "single")
        }
        if let titles = dataDict["choices"] as? [String] {
            self.titles = titles
        }
    }

    override func initResults(results : [String: AnyObject]) {
        self.result = ChoicesResult(task: self, results: results)
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["selections"] = (isRadio ? "single" : "multiple") as AnyObject
        dict["choices"] = titles as AnyObject?
        return dict
    }

    override func taskDescriptionString() -> String {
        var descriptionString = isRadio ? "Select one of: " : "Select any of: "
        var selectionString : String?
        for selection in titles {
            if selectionString == nil {
                selectionString = selection
            } else {
                selectionString = ", " + selection
            }
            descriptionString += selectionString!
        }
        return descriptionString
    }
}

// MARK: ChoicesResult Class -------------------------------------------------------------------------------
class ChoicesResult : TaskResult {
    var values = [Bool]()

    override init(task : Task, results: [String : AnyObject]) {
        super.init(task: task, results: results)
        if let resultValues = results["values"] as? [Bool] {
            for value in resultValues {
                values += [value]
            }
        }
    }

    func save(newValues: [Bool]) {
        values.removeAll()
        _completed = false
        for newValue in newValues {
            values += [newValue]
            if newValue {
                _completed = true;
            }
        }
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()

        dict["values"] = values as AnyObject?
        return dict
    }

    override func description() -> String {
        var text = "Done: "
        if let choicesTask = task as? ChoicesTask {
            var checked = 0
            for (value, choice) in zip(values, choicesTask.titles) {
                if value {
                    // separate with checkmarks.
                    if checked > 0 {
                        text += ", "
                    }
                    text += choice
                    checked += 1
                }
            }
            if checked == 0 {
                text += "No choices selected"
            }
        }

        return text
    }
}
