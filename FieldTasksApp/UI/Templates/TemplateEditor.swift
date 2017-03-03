//
//  TemplateEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TemplateEditor : UIViewController, TemplateTasksToolProtocol {
    var listController : TemplateEditorTable?
    var template : Template?
    @IBOutlet weak var toolbar: TasksToolbar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var templateTitleLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.delegate = self

        self.title = template!.name.characters.count > 0 ? "Create Template" : "New Template"
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(doneAction))
        makeNavBarFlat()
        self.view.backgroundColor = UIColor.wetAsphalt()

        // Do any additional setup after loading the view, typically from a nib.
        titleLabel.makeDetailStyle()
        templateTitleLabel.makeTitleStyle()
        titleField.setActiveStyle(isActive: true)
        titleField.text = template!.name
        titleField.addHideKeyboardButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? TemplateEditorTable
        listController?.parentTemplateEditor = self
        if template == nil {
            template = Template()
        }
        listController?.tasks = self.template!.tasks
    }

    func addTask(taskType: TaskType) {
        if let task = TaskFromType(type: taskType) {
            listController?.tasks += [task]
            listController?.openTaskEditor(task: task)
        }
    }

    func cancelAction () {
        self.dismiss(animated: true) { }
    }

    func doneAction () {
        template?.tasks = (listController?.tasks)!
        template?.name = titleField.text!
        self.dismiss(animated: true) { }
    }
    
}
