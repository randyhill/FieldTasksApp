//
//  TemplatesTable.swift
//  FieldTasksApp
//
//  Created by CRH on 2/23/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TemplateCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tasks: UILabel!
    @IBOutlet weak var body: UILabel!
}

class TemplatesTable: UITableViewController {
    var templatesList = [Template]()
    var parentTemplatesViewer : TemplatesViewer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
        tableView.backgroundColor = Globals.shared.bgColor
        self.refreshList()

        switch parentTemplatesViewer!.style {
        case .List:
            break
        case .Location:
            break
        case .Picker:
            self.tableView.allowsMultipleSelection = true
        }
    }

    func refreshList() {
        TemplatesManager.shared.refreshList(location: parentTemplatesViewer?.location) { (templates, err ) in
            if let error = err {
                FTErrorMessage(error: "Failed to load forms: \(error)")
            } else {
                if let templates = templates {
                    self.templatesList = templates
                    self.refreshOnMainThread()
                }
            }
        }
    }

    func selectedTemplates() -> [Template]? {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            return selectedRows.map { (indexPath) -> Template in
                let row = indexPath.row
                return templatesList[row]
            }
        }
        return nil
    }

    func refreshOnMainThread() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let templateEditor = navController.topViewController as? TemplateEditor {
                templateEditor.template = sender as? Template
            }
        }
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    func toggleEdit(button : FUIButton) {
        tableView.isEditing = !tableView.isEditing
        let title = tableView.isEditing ? "Done" : "Edit"
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templatesList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.isEditing = false
            let template = self.templatesList[indexPath.row]
            self.performSegue(withIdentifier: "OpenTemplateEditor", sender: template)
        }
        edit.backgroundColor = UIColor.peterRiver()

        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.isEditing = false
            self.deleteTemplate(forRowAt: indexPath)
        }
        delete.backgroundColor = UIColor.alizarin()

        return [edit, delete]
    }

    func deleteTemplate(forRowAt indexPath: IndexPath) {
        self.askAlert(title: "Are you sure you want to delete this template?", body: "Deletion is permanent and can't be undone", action: "Delete", completion: { (canceled) in
            if !canceled {
                let template = self.templatesList[indexPath.row]
                TemplatesManager.shared.deleteTemplate(templateId: template.id, completion: { (error) in
                    if let error = error {
                        self.showAlert(title: "Delete failed", message: "Unable to delete template: \(error)")
                    } else {
                        self.templatesList = TemplatesManager.shared.templateList()
                        self.refreshOnMainThread()
                    }
                })
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath as IndexPath)
        if let cell = cell as? TemplateCell {
            let form = templatesList[indexPath.row]
            cell.title!.text = form.name
            cell.tasks!.text = "\(form.tasks.count)"
            if form.description.characters.count > 0 {
                cell.body!.text = "Description: \(form.description)"
            } else {
                cell.body!.text = ""
            }
            cell.makeCellFlat(backgroundColor: tableView.backgroundColor!, selectedColor: UIColor.sunflower())
            cell.title.makeTitleStyle()
            cell.tasks.makeTitleStyle()
            cell.body.makeDetailStyle()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if parentTemplatesViewer?.style == .Picker {

        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let formController = storyboard.instantiateViewController(withIdentifier: "FormTasksViewer") as? FormTasksViewer {
                // Create form so it's editable.
                formController.form = Form(template: templatesList[indexPath.row])
                let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }
}
