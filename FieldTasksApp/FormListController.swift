//
//  FormListController
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class FormListController: UITableViewController {
    var formsList = [Template]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Forms"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(goBack))
        makeNavBarFlat()

        self.refreshList()
    }

    func goBack() {
        self.dismiss(animated: true) { 

        }
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.loadTemplates { (result, error) in
            if error != nil {
                print("Failed to load forms: \(error)")
            } else {
                if let formList = result  {
                    self.formsList.removeAll()
                    for formObject in formList {
                        if let formDict = formObject as? [String : AnyObject] {
                            self.formsList += [Template(templateDict: formDict)]
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                 }

            }
        }
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
        return formsList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormCell", for: indexPath as IndexPath)
        let form = formsList[indexPath.row]
        cell.textLabel!.text = "\(form.name) Tasks: \(form.tasks.count)"
        cell.detailTextLabel!.text = "Description: \(form.description)"
        cell.makeCellFlat()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "TemplateController") as? TemplateController {
            formController.form = Form(template: formsList[indexPath.row])
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}

