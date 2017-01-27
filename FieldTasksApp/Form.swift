//
//  Form.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    var createDate = Date()

    init(formDict : [String : AnyObject]) {
        super.init(templateDict: formDict)
        if let createDate = formDict["createDate"] as? String {
            if let date = Globals.shared.utcFormatter.date(from: createDate) {
                self.createDate = date
            }
        }
    }

    override init(template: Template) {
        super.init(template: template)
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["createDate"] = Globals.shared.utcFormatter.string(from: createDate) as AnyObject?
        return formDict
    }

    func submit(controller: UIViewController) {
        // upload all the Photos from PhotoTasks first.
        ServerMgr.shared.uploadImages(photoFileList: PhotoFileList(tasks: tasks), completion: { (photoFileList, error) in
            if let _ = photoFileList {
                // Photo file names should have been copied to photo tasks, we can submit form now
                ServerMgr.shared.saveAsForm(form: self) { (result, error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: "Form Submission Failed: \(error!)")
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "Form submitted successfuly")
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: "Photos upload failed because of: \(error!)")
            }

        })
    }
}
