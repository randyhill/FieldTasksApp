//
//  MainController.swift
//  FieldTasksApp
//
//  Created by CRH on 1/18/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class MainController: UITableViewController {
    var formsList = [Form]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Welcome"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))

        self.refreshList()
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerManager.sharedInstance.loadForms { (result, error) in
            if error != nil {
                print("Failed to load forms: \(error)")
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

        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formsList.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell", for: indexPath as IndexPath)
        if indexPath.row == 0 {
            cell.textLabel!.text = "Tap to Add New Form +"
            cell.detailTextLabel!.text = ""
        } else {
            let form = formsList[indexPath.row-1]
            cell.textLabel!.text = form.name
            cell.detailTextLabel!.text = Globals.sharedInstance.dateFormatter.string(from: form.createDate)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormListController") as? FormListController {
                let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        } else {
            if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormController") as? FormController {
                formController.form = formsList[indexPath.row - 1]
                let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }
}

