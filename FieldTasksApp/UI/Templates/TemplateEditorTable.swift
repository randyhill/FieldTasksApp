//
//  TemplateEditorTable.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

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
        self.typeText.text = task.type.rawValue + (task.required ? " (Required)" : "")
        self.titleText.text = task.name
        self.descriptionText.text = "Description: \(task.description)"
        self.lengthText.text = task.taskDescriptionString()
    }
}

class TemplateEditorTable : UITableViewController {
    var parentTemplateEditor : TemplateEditor?
    var tasks = [Task]()

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

    func removeLast() {
        if tasks.count > 0 {
            tasks.removeLast()
            self.tableView.reloadData()
        }
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    func toggleEditing(button : FUIButton) {
        tableView.isEditing = !tableView.isEditing
        let title = tableView.isEditing ? "Done" : "Edit"
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTask = tasks[sourceIndexPath.row]
        tasks[sourceIndexPath.row] = tasks[destinationIndexPath.row]
        tasks[destinationIndexPath.row] = movedTask

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return tasks.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
        } else {
            print("unimplemented editing style")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let task = tasks[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.initWithTask(task: task)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openTaskEditor(task: tasks[indexPath.row])
    }

    func openTaskEditor(task : Task) {
        if let taskEditor = self.storyboard?.instantiateViewController(withIdentifier: "TaskEditor") as? TaskEditor {
            // Create form so it's editable.
            taskEditor.task = task
            taskEditor.parentController = self
            let navController = UINavigationController(rootViewController: taskEditor) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
