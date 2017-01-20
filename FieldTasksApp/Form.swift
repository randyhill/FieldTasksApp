//
//  Form.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation

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
    func isComplete() -> Bool {
        for task in tasks {
            if !task.isComplete() {
                return false
            }
        }
        return true
    }
}

class Form : Template {
//    var id = ""
//    var name = ""
//    var description = ""
//    var tasks = [FormTask]()
    var createDate = Date()

    init(formDict : [String : AnyObject]) {
        super.init(templateDict: formDict)
        if let createDate = formDict["createDate"] as? String {
            if let date = Globals.sharedInstance.utcFormatter.date(from: createDate) {
                self.createDate = date
            }
        }
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["createDate"] = Globals.sharedInstance.utcFormatter.string(from: createDate) as AnyObject?
        return formDict
    }
}
