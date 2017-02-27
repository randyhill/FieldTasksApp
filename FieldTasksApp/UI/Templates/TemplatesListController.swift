//
//  TemplatesListController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/23/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TemplateCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tasks: UILabel!
    @IBOutlet weak var body: UILabel!
}

class TemplatesListController: UITableViewController {
    var templatesList = [Template]()
    var parentTemplatesController : TemplatesController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
        tableView.backgroundColor = UIColor.greenSea()
        self.refreshList()
    }

    func refreshList() {
        TemplatesManager.shared.refreshList(location: parentTemplatesController?.location) { (templates, err ) in
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

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templatesList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
        } else {
            print("unimplemented editing style")
        }
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
            cell.makeCellFlat()
            cell.title.makeTitleStyle()
            cell.tasks.makeTitleStyle()
            cell.body.makeDetailStyle()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormTasksController") as? FormTasksController {
            // Create form so it's editable.
            formController.form = Form(template: templatesList[indexPath.row])
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {
                
            })
        }
    }
}
