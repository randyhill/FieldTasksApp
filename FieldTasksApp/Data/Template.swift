//
//  Template.swift
//  FieldTasksApp
//
//  Created by CRH on 2/7/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class Template {
    var id = ""
    var name = ""
    var description = ""
    var tasks = [FormTask]()

    init(templateDict : [String : AnyObject]) {
        if let name = templateDict["name"] as? String {
            self.name = name
        }
        if let description = templateDict["description"] as? String {
            self.description = description
        }
        if let id = templateDict["_id"] as? String {
            self.id = id
        }
        if let tasksArray = templateDict["tasks"] as? [AnyObject] {
            for taskObject in tasksArray {
                if let taskDict = taskObject as? [String : AnyObject] {
                    self.tasks += [FormTask(taskDict: taskDict)]
                }
            }
        }
    }

    init(template: Template) {
        self.id = template.id
        self.name = template.name
        self.description = template.description
        self.tasks = template.tasks
    }

    func toDict() -> [String : AnyObject]{
        var formDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        formDict["name"] = name as AnyObject?
        formDict["description"] = description as AnyObject?
        //formDict["id"] = id as AnyObject?
        var taskDicts = [[String : AnyObject]]()
        for task in tasks {
            taskDicts += [task.toDict()]
        }
        formDict["tasks"] = taskDicts as AnyObject?
        return formDict
    }

    func tasksStillIncomplete() -> String? {
        var incompleteTasks : String?
        for task in tasks {
            if !task.isComplete() {
                if incompleteTasks == nil {
                    incompleteTasks = ""
                } else {
                    incompleteTasks! += ", "
                }
                incompleteTasks! += task.name
            }
        }
        return incompleteTasks
    }
}
