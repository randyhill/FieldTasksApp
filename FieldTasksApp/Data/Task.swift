//
//  Task.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

enum TaskType : String {
    case Text = "Text",
    Number = "Number",
    Choices = "Choices",
    Photos = "Photos",
    Unknown = "Unknown"
}

enum TaskDictFields : String {
    case type = "type",
    id = "_id",
    name = "name",
    required = "required",
    description = "description",
    results = "results",
    data = "data"
}

// MARK: Task Factories -------------------------------------------------------------------------------
func TaskFromDictionary(taskDict : [String : AnyObject]) -> Task? {
    var newTask : Task?
    if let typeString = taskDict[TaskDictFields.type.rawValue] {
        switch typeString as! String {
        case TaskType.Text.rawValue:
            newTask = TextTask(taskDict: taskDict)
        case TaskType.Number.rawValue:
            newTask = NumberTask(taskDict: taskDict)
        case TaskType.Choices.rawValue:
            newTask = ChoicesTask(taskDict: taskDict)
        case TaskType.Photos.rawValue:
            newTask = PhotosTask(taskDict: taskDict)
        default:
            FTErrorMessage(error: "Unknown class in task generator")
        }
    } else {
        FTErrorMessage(error: "Could not get type of task")
    }
    return newTask
}

func TaskFromType(type : TaskType) -> Task? {
    var newTask : Task?
    let emptyDict = [String: AnyObject]()
    switch type {
    case TaskType.Text:
        newTask = TextTask(taskDict: emptyDict)
    case TaskType.Number:
        newTask = NumberTask(taskDict: emptyDict)
    case TaskType.Choices:
        newTask = ChoicesTask(taskDict: emptyDict)
    case TaskType.Photos:
        newTask = PhotosTask(taskDict: emptyDict)
    default:
        FTErrorMessage(error: "Unknown class in task generator")
    }
    return newTask
}

// MARK: Task Class -------------------------------------------------------------------------------
class Task {
    var type = TaskType.Unknown
    var id = ""
    var name = ""
    var required = false
    var description = ""
    var result : TaskResult?
    var editorId : String { get { return ""} }
    var viewerId : String { get { return ""} }

    init() {
    }

    init(taskDict : [String : AnyObject]) {
        if let name = taskDict["name"] as? String {
            self.name = name
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
        var dataDict = taskDict["data"] as? [String : AnyObject]
        if (dataDict == nil) {
            dataDict = [String : AnyObject]()
        }
        initTaskDescription(dataDict: dataDict!)

        var results = taskDict["results"] as? [String : AnyObject]
        if (results == nil) {
            results = [String : AnyObject]()
        }
        initResults(results: results!)
    }

    func initTaskDescription(dataDict : [String: AnyObject]) {
        FTErrorMessage(error: "This function must be overridden")
    }


    func initResults(results : [String: AnyObject]) {
        FTErrorMessage(error: "This function must be overridden")
    }


    func toDict() -> [String : AnyObject]{
        var taskDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        taskDict["name"] = name as AnyObject?
        taskDict["type"] = type.rawValue as AnyObject?
        taskDict["required"] = required as AnyObject?
        taskDict["description"] = description as AnyObject?
        taskDict["data"] = taskDescriptionDict() as AnyObject?
        taskDict["results"] = result!.toDict() as AnyObject?
        taskDict["name"] = name as AnyObject?
        return taskDict
    }

    func taskDescriptionDict() -> [String : AnyObject] {
        return [String : AnyObject]()
    }

    func taskDescriptionString() -> String {
        return ""
    }

    func isComplete() -> Bool {
        if !required {
            return true
        }
        return result!.completed
    }
}

// MARK: TaskResult Class -------------------------------------------------------------------------------
class TaskResult {
    var _completed = false
    var task : Task?
    var completed: Bool {
        get {
            return _completed
        }
    }
    init(task : Task, results: [String : AnyObject]) {
        self.task = task
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










