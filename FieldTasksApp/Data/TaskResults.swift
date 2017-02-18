//
//  TaskResults.swift
//  FieldTasksApp
//
//  Created by CRH on 8/24/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit


class TaskResult {
    var _completed = false
    var formTask : FormTask?
    var completed: Bool {
        get {
            return _completed
        }
    }
    init(formTask : FormTask, results: [String : AnyObject]) {
        self.formTask = formTask
    }

    func toDict() -> [String : AnyObject]{
        var dict = [String : AnyObject]()
        dict["completed"] = completed as AnyObject?
        return dict
    }

    func save(newText : String) {

    }

    func description() -> String {
        return ""
    }
}

class TextResult : TaskResult {
    var text = ""

    override init(formTask : FormTask, results: [String : AnyObject]) {
        super.init(formTask: formTask, results: results)

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

class NumberResult : TaskResult {
    var value : Double?

    override init(formTask : FormTask, results: [String : AnyObject]) {
        super.init(formTask: formTask, results: results)

        if let valueResult = results["number"] as? Double {
            value = valueResult
        }
     }

    override func save(newText : String) {
        _completed = false
        if let newValue = Double(newText) {
            value = newValue
            if let numberDescription = formTask?.taskDescription as? NumberTaskDescription, let value = value {
                if numberDescription.isUnlimited || (value >= numberDescription.min && value <= numberDescription.max) {
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
        if let description =  formTask?.taskDescription as? NumberTaskDescription {
            if let numberValue = value {
                if description.isDecimal {
                    return "\(numberValue)"
                } else {
                    return "\(numberValue.toInt())"
                }
            }
        }
        return ""
    }
}

class ChoicesResult : TaskResult {
    var values = [Bool]()

    override init(formTask : FormTask, results: [String : AnyObject]) {
        super.init(formTask: formTask, results: results)
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
        if let choicesTask = formTask?.taskDescription as? ChoicesTaskDescription {
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

class PhotoResult : TaskResult {
    var photos = [UIImage]()
    var fileNames = [String]()
    override var completed: Bool {
        get {
            return (photos.count > 0)
        }
    }

    override init(formTask : FormTask, results: [String : AnyObject]) {
        super.init(formTask: formTask, results: results)
        if let fileNames = results["fileNames"] as? [String] {
            self.fileNames = fileNames
        }
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["fileNames"] = fileNames as AnyObject?
        return dict
    }
}
