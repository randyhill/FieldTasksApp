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
        //self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        tableView.backgroundColor = UIColor.greenSea()
        self.refreshList()
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.loadTemplates(location: parentTemplatesController?.location) { (result, error) in
            if error != nil {
                FTErrorMessage(error: "Failed to load forms: \(error)")
            } else {
                if let formList = result  {
                    DispatchQueue.main.async(execute: {
                        self.templatesList.removeAll()
                        for formObject in formList {
                            if let formDict = formObject as? [String : AnyObject] {
                                self.templatesList += [Template(templateDict: formDict)]
                            }
                        }
                        self.tableView.reloadData()
                    })
                }

            }
        }
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
