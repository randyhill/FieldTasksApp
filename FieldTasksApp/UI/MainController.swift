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
    var location : Location?    // Filter by location if set

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Forms"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshList))
        if location != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(goBack))
        }
        makeNavBarFlat()
    }

    func goBack() {
        self.dismiss(animated: true) {

        }
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        ServerMgr.shared.loadForms(location: location) { (result, error) in
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

        self.refreshList()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return formsList.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath as IndexPath)
            cell.textLabel?.text = "Complete New Form"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldFlatFont(ofSize: 17)
            cell.configureHeaderCell()
            return cell
      } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell", for: indexPath as IndexPath)
            let form = formsList[indexPath.row]
            cell.textLabel!.text = form.name
            cell.detailTextLabel!.text = Globals.shared.dateFormatter.string(from: form.createDate)
            cell.makeCellFlat()
            return cell
       }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let formController = self.storyboard?.instantiateViewController(withIdentifier: "TemplatesController") as? TemplatesController {
                formController.location = location
                 let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        } else {
            if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormController") as? FormController {
                formController.form = formsList[indexPath.row]
                let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }
}

