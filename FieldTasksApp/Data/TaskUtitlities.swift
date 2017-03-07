//
//  Task.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

// MARK: Task Factories -------------------------------------------------------------------------------
func TaskFromDictionary(taskDict : [String : AnyObject]) -> Task? {
    var newTask : Task?
    if let typeString = taskDict[TaskDictFields.type.rawValue] {
        switch typeString as! String {
        case TaskType.Text.rawValue:
            newTask = TextTask()
        case TaskType.Number.rawValue:
            newTask = NumberTask()
        case TaskType.Choices.rawValue:
            newTask = ChoicesTask()
        case TaskType.Photos.rawValue:
            newTask = PhotosTask()
        default:
            FTErrorMessage(error: "Unknown class in task generator")
        }
        newTask?.fromDict(taskDict: taskDict)
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
        newTask = TextTask()
    case TaskType.Number:
        newTask = NumberTask()
    case TaskType.Choices:
        newTask = ChoicesTask()
    case TaskType.Photos:
        newTask = PhotosTask()
    default:
        FTErrorMessage(error: "Unknown class in task generator")
    }
    newTask?.fromDict(taskDict: emptyDict)
   return newTask
}










