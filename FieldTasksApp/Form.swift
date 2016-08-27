//
//  Form.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation

class Form {
    var id = ""
    var name = ""
    var description = ""
    var tasks = [FormTask]()

    init(formDict : [String : AnyObject]) {
        if let name = formDict["name"] as? String {
            self.name = name
        }
        if let description = formDict["description"] as? String {
            self.description = description
        }
        if let id = formDict["_id"] as? String {
            self.id = id
        }
        if let tasksArray = formDict["tasks"] as? [AnyObject] {
            for taskObject in tasksArray {
                if let taskDict = taskObject as? [String : AnyObject] {
                    self.tasks += [FormTask(taskDict: taskDict)]
                }
            }
        }
    }

    func toDict() -> [String : AnyObject]{
        var formDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        formDict["name"] = name
        formDict["description"] = description
        var taskDicts = [[String : AnyObject]]()
        for task in tasks {
            taskDicts += [task.toDict()]
        }
        formDict["tasks"] = taskDicts
        return formDict
    }

    func isComplete() -> Bool {
        for task in tasks {
            if !task.isComplete() {
                return false
            }
        }
        return true
    }
}