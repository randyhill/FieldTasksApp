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


enum TaskClassType : String {
    case Text = "TextTask",
    Number = "NumberTask",
    Choices = "ChoicesTask",
    Photos = "PhotosTask",
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
    if let typeString = taskDict[TaskDictFields.type.rawValue] as? String {
        let entityName = typeString + "Task"
        newTask = CoreDataMgr.shared.createTask(entityName: entityName)
        newTask?.fromDict(taskDict: taskDict)
    } else {
        FTErrorMessage(error: "Could not get type of task")
    }
    return newTask
}

func TaskFromType(type : TaskType) -> Task? {
    let entityName = type.rawValue + "Task"
   return CoreDataMgr.shared.createTask(entityName: entityName)
}










