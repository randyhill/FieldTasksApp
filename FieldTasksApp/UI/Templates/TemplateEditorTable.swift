//
//  TemplateEditorTable.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TaskCell : UITableViewCell {
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var lengthText: UILabel!
    func initWithTask(task : Task) {
        // Make flat
        self.makeCellFlat()
        self.titleText.makeTitleStyle()
        self.typeText.makeTitleStyle()
        self.descriptionText.makeDetailStyle()
        self.lengthText.makeDetailStyle()

        // Enter text
        self.typeText.text = task.type.rawValue
        self.titleText.text = task.name
        self.descriptionText.text = "Description: \(task.description)"
        self.lengthText.text = task.taskDescriptionString()
    }
}

class TemplateEditorTable : UITableViewController {
    var parentTemplateEditor : TemplateEditor?
    var template : Template?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
        tableView.backgroundColor = UIColor.greenSea()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasks = template?.tasks {
            return tasks.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.askAlert(title: "Are you sure you want to delete this template?", body: "Deletion is permanent and can't be undone", action: "Delete", completion: { (canceled) in
//                if !canceled {
//                    let template = self.template.tasks[indexPath.row]
//                    TemplatesManager.shared.deleteTemplate(templateId: template.id, completion: { (error) in
//                        if let error = error {
//                            self.showAlert(title: "Delete failed", message: "Unable to delete template: \(error)")
//                        } else {
//                            self.templatesList = TemplatesManager.shared.templateList()
//                            self.refreshOnMainThread()
//                        }
//                    })
//                }
            })
        } else {
            print("unimplemented editing style")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let task = template?.tasks[indexPath.row] {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
                cell.initWithTask(task: task)
                return cell
            }
        }
        FTErrorMessage(error: "Bad cell type")
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = template?.tasks[indexPath.row] {
            openTaskEditor(task: task)
        }
    }

    func openTaskEditor(task : Task) {
        if let taskEditor = self.storyboard?.instantiateViewController(withIdentifier: "TaskEditor") as? TaskEditor {
            // Create form so it's editable.
            taskEditor.task = task
            let navController = UINavigationController(rootViewController: taskEditor) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
