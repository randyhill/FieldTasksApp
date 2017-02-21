//
//  FormsListController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/20/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class FormsListController: UITableViewController {
    var parentFormsController : FormsController?
    var formsList = [Form]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
        self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)

        tableView.backgroundColor = UIColor.greenSea()
    }


    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        let location = parentFormsController?.location;
        ServerMgr.shared.loadForms(location: location) { (result, error) in
            if error != nil {
                FTErrorMessage(error: "Failed to load forms: \(error)")
            } else {
                if let formList = result  {
                    self.formsList.removeAll()
                    for formObject in formList {
                        if let formDict = formObject as? [String : AnyObject] {
                            self.formsList += [Form(formDict: formDict)]
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

        self.refreshList()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formsList.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell", for: indexPath as IndexPath)
        let form = formsList[indexPath.row]
        cell.textLabel!.text = form.name
        cell.detailTextLabel!.text = Globals.shared.dateFormatter.string(from: form.createDate)
        cell.makeCellFlat()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormController") as? FormController {
            formController.form = formsList[indexPath.row]
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {
                
            })
        }
    }
}
