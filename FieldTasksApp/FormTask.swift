//
//  Task.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class FormTask {
    var id = ""
    var name = ""
    var type = ""
    var required = false
    var description = ""
    var taskDescription : TaskDescription?
    var result : TaskResult?

    init(taskDict : [String : AnyObject]) {
        if let name = taskDict["name"] as? String {
            self.name = name
        }
        if let type = taskDict["type"] as? String {
            self.type = type
        }
        if let id = taskDict["_id"] as? String {
            self.id = id
        }
        if let required = taskDict["required"] as? String {
            self.required = (required == "true")
        }
        if let description = taskDict["description"] as? String {
            self.description = description
        }
        var results = taskDict["results"] as? [String : AnyObject]
        if (results == nil) {
            results = [String : AnyObject]()
        }

        // Some tasks might not have custom data, so allocate the data either way
        var data = taskDict["data"] as? [String : AnyObject]
        if (data == nil) {
            data = [String : AnyObject]()
        }
        switch type {
            case "Text":
                self.taskDescription = TextTaskDescription(dataDict: data!)
                self.result = TextResult(formTask: self, results: results!)
            case "Number":
                self.taskDescription = NumberTaskDescription(dataDict: data!)
                self.result = NumberResult(formTask: self, results: results!)
            case "Choices":
                self.taskDescription = ChoicesTaskDescription(dataDict: data!)
                self.result = ChoicesResult(formTask: self, results: results!)
            case "Photo":
                self.taskDescription = PhotoTaskDescription(dataDict: data!)
                self.result = PhotoResult(formTask: self, results: results!)
            default:
                print("can't find type of data")
                self.taskDescription = TaskDescription(dataDict: data!)
                self.result = TaskResult(formTask: self, results: results!)
        }
    }

    func toDict() -> [String : AnyObject]{
        var taskDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        taskDict["name"] = name as AnyObject?
        taskDict["type"] = type as AnyObject?
        taskDict["required"] = required as AnyObject?
        taskDict["description"] = description as AnyObject?
        taskDict["data"] = taskDescription!.toDict() as AnyObject?
        taskDict["results"] = result!.toDict() as AnyObject?
        taskDict["name"] = name as AnyObject?
        return taskDict
    }

    func isComplete() -> Bool {
        if !required {
            return true
        }
        return result!.completed
    }
}

