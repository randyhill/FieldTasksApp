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
    var tasks = [Task]()

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
                    self.tasks += [Task(taskDict: taskDict)]
                }
            }
        }
    }
}