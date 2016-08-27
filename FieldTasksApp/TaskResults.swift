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
        dict["completed"] = completed
        return dict
    }

    func save(newText : String) {

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
        dict["text"] = text
        return dict
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
            dict["number"] = numberValue
        }
        return dict
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

        dict["values"] = values
        return dict
    }
}

class PhotoResult : TaskResult {
    var photo : UIImage?

    func save(newPhoto: UIImage?) {
        photo = newPhoto
        completed = (newPhoto != nil)
    }
}