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










