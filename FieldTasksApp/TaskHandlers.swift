//
//  TaskHandlers.swift
//  FieldTasksApp
//
//  Created by CRH on 8/22/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

// MARK: Task Handlers -------------------------------------------------------------------------------
class TaskHandler : NSObject {
    var task : FormTask?
    var isEditable = true
    var container : UIView?
    var controller : UIViewController?

    init(controller : UIViewController, container : UIView, task: FormTask, isEditable: Bool) {
        self.task = task
        self.container = container
        self.controller = controller
        self.isEditable = isEditable
    }

    // Return nil if data user entered is valid or error message if not
    func validate() -> String? {
        return nil
    }

    func save() {

    }

    func restore() {

    }
}


class WorkerTaskHandler : TaskHandler {

}

class CustomerTaskHandler : TaskHandler {
    
}
