//
//  TemplateEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TemplateEditor : UIViewController, TemplateTasksToolProtocol {
    var listController : TemplateEditorTable?
    var template : Template?
    @IBOutlet weak var toolbar: TasksToolbar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var templateTitleLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var editButton: FUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.delegate = self

        self.title = template!.name!.characters.count > 0 ? "Edit Form" : "New Form"
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Save", target: self, action: #selector(doneAction))
        makeNavBarFlat()
        self.view.backgroundColor = UIColor.wetAsphalt()

        // Do any additional setup after loading the view, typically from a nib.
        titleLabel.makeDetailStyle()
        templateTitleLabel.makeTitleStyle()
        titleField.setActiveStyle(isActive: true)
         titleField.addHideKeyboardButton()
        editButton.makeFlatButton()
        editButton.isHidden = true
        if let template = template {
            let title = template.name == "" ? "New Form" : template.name
            titleField.text = title
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? TemplateEditorTable
        listController?.parentTemplateEditor = self
        if template == nil {
            template = CoreDataMgr.createTemplate(context: CoreDataMgr.shared.mainThreadContext!)
        }
        listController?.tasks = self.template!.tasks
    }

    func addTask(taskType: TaskType) {
        if let task = TaskFromType(context: CoreDataMgr.shared.mainThreadContext!, type: taskType) {
            listController?.tasks += [task]
            listController?.openTaskEditor(task: task)
            editButton.isHidden = false
        }
    }

    @IBAction func toggleEditing(_ sender: Any) {
        listController?.toggleEditing(button: editButton)
    }

    func cancelAction () {
        if isEmptyTemplate(template: template!) {
            // Don't save newly created/empty objects
            CoreDataMgr.deleteObject(context: CoreDataMgr.shared.mainThreadContext!, object: template!)
        }
        self.dismiss(animated: true) { }
    }

    func isEmptyTemplate(template: Template) -> Bool {
        if template.id!.characters.count > 0 { return false }
        if template.name!.characters.count > 0 { return false }
        if template.tasks.count > 0 {
            template.name = "Untitled"
            return false
        }
        return true
    }

    func doneAction () {
        if let template = template {
            template.tasks = (listController?.tasks)!
            template.name = titleField.text!
            if isEmptyTemplate(template: template) {
                // Don't save empties
                CoreDataMgr.deleteObject(context: CoreDataMgr.shared.mainThreadContext!, object: template)
            } else {
                TemplatesMgr.shared.updateTemplate(template: template)
                self.dismiss(animated: true) { }
            }
        }
    }
    
}
