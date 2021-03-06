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

        switch parentTemplatesViewer!.style {
        case .List:
            break
        case .Location:
            break
        case .Picker:
            self.tableView.allowsMultipleSelection = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateList()
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

    // MARK: Refresh Methods -------------------------------------------------------------------------------

    func serverRefresh() {
        SyncMgr.shared.sync(context: CoreDataMgr.shared.mainThreadContext!, completion: { (syncResult) in
            if let error = syncResult.error {
                self.showAlert(title: "Error syncing with server", message: error)
            }
            // Refresh list data before updating visual list
            if syncResult.locations > 0 {
                self.updateList()
            }
        })
    }

    func updateList() {
        let templates = TemplatesMgr.shared.all()
        switch parentTemplatesViewer!.style {
        case .List:
            self.templatesList = templates
        case .Picker:
            self.templatesList = self.filterTemplates(location: self.parentTemplatesViewer!.location!, templates: templates)
        case .Location:
            if let location = parentTemplatesViewer?.location {
                self.templatesList = TemplatesMgr.shared.templatesFromId(idList: location.templateIds())
            }
        }
        // Sort alphabetically
        self.templatesList = self.templatesList.sorted(by: { (a , b ) -> Bool in
            return a.name! < b.name!
        })
        self.refreshOnMainThread()
    }

    func filterTemplates(location: FTLocation, templates: [Template]) -> [Template] {
        return templates.filter({ (template) -> Bool in
            return !location.containsTemplate(templateId: template.id!)
        })
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
        if parentTemplatesViewer?.style == .Picker {
            return false
        }
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
            //self.isEditing = false
            if self.parentTemplatesViewer?.style == .List {
                self.deleteTemplateFromServer(forRowAt: indexPath)
            } else {
                self.removeTemplateFromLocation(forRowAt: indexPath)
            }
        }
        delete.backgroundColor = UIColor.alizarin()

        return [edit, delete]
    }

    func removeTemplateFromLocation(forRowAt indexPath: IndexPath) {
        if let location = self.parentTemplatesViewer?.location {
            let template = self.templatesList[indexPath.row]
            location.removeTemplate(templateId: template.id!)
            NetworkOpsMgr.shared.updateLocation(location: location)
            self.updateList()
        }
    }

    func deleteTemplateFromServer(forRowAt indexPath: IndexPath) {
        self.askAlert(title: "Are you sure you want to delete this form?", body: "Deletion is permanent and can't be undone", action: "Delete", completion: { (deleteIt) in
            if deleteIt {
                let template = self.templatesList[indexPath.row]
                TemplatesMgr.shared.deleteTemplate(templateId: template.id!)
                self.templatesList = TemplatesMgr.shared.all()
                self.refreshOnMainThread()
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath as IndexPath)
        if let cell = cell as? TemplateCell {
            let template = templatesList[indexPath.row]
            cell.title!.text = template.name
            cell.tasks!.text = "\(template.tasks.count)"
            if template.descriptionString!.count > 0 {
                cell.body!.text = "Description: \(template.descriptionString!)"
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
        if parentTemplatesViewer?.style != .Picker {
            let template = templatesList[indexPath.row]
            if let form = FormsMgr.shared.formExists(context: CoreDataMgr.shared.mainThreadContext!, templateId: template.id!) {
                self.askAlert(title: "Continue using previous Form?", body: "You did not submit the previous version of this form, would you like to continue filling it out?", action: "OK", cancel: "No", completion: { (usePreviousForm) in
                    let form = usePreviousForm ? form : FormsMgr.shared.newForm(context: CoreDataMgr.shared.mainThreadContext!, template: template)
                    self.openFormViewer(form: form)
                })
            } else {
                let form = FormsMgr.shared.newForm(context: CoreDataMgr.shared.mainThreadContext!, template: template)
                self.openFormViewer(form: form)
            }
        }
    }

    func openFormViewer(form: Form) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let formController = storyboard.instantiateViewController(withIdentifier: "FormTasksViewer") as? FormTasksViewer {
            // Create form so it's editable.
            formController.form = form
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
