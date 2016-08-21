//
//  Task.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation

class Task {
    var id = ""
    var name = ""
    var type = ""
    var description = ""

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
        if let description = taskDict["description"] as? String {
            self.description = description
        }
    }
    
}