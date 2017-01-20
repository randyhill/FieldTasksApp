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

    init(formTask : FormTask) {
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
        return "\(value)"
    }
}

class ChoicesResult : TaskResult {
    var values = [Bool]()

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
        var text = ""
        if let choicesTask = formTask?.taskDescription as? ChoicesTaskDescription {
            var index = 1
            for (value, choice) in zip(values, choicesTask.titles) {
                text += "\(choice): \(value) "
                index += 1
            }
        }

        return text
    }
}

class PhotoResult : TaskResult {
    var photo : UIImage?

    func save(newPhoto: UIImage?) {
        photo = newPhoto
        completed = (newPhoto != nil)
    }
}
