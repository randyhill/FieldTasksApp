//
//  TaskResults.swift
//  FieldTasksApp
//
//  Created by CRH on 8/24/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit


class TaskResult {
    var completed = false
    var formTask : FormTask?

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
        completed = false
        text = newText
        if text.characters.count > 0 {
            completed = true
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
//    var value : Double {
//        get {
//            return _value ?? 0.0
//        }
//        set(newValue) {
//            _value = new
//        }
//    }

    override init(formTask : FormTask, results: [String : AnyObject]) {
        super.init(formTask: formTask, results: results)

        if let valueResult = results["number"] as? Double {
            value = valueResult
        }
     }

    override func save(newText : String) {
        completed = false
        if let newValue = Double(newText) {
            value = newValue
            completed = true
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
                    let intValue  = Int(numberValue)
                    return "\(intValue)"
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
        for newValue in newValues {
            values += [newValue]
        }
        if formTask!.required {
            completed = values.count > 0
        } else {
            completed = true
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

    func save(newPhoto: UIImage?) {
        if let photo = newPhoto {
            photos += [photo]
        }
        completed = (newPhoto != nil)
    }
}
