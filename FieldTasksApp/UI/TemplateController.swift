//
//  TemplateController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class TemplateController : UITableViewController {
    var form : Template?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Form: \(form!.name)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(submitForm))
        configureNavBar()
    }

    func goBack(){
        dismiss(animated: true, completion: nil)
    }

    func submitForm() {
        if !form!.isComplete() {
            self.showAlert(title: "Form Incomplete", message: "You must complete all required fields before submitting the form")
        } else {
            ServerManager.sharedInstance.saveAsForm(form: form!) { (result, error) in
                if error != nil {
                    self.showAlert(title: "Form Submission Failed", message: error!)
                } else {
                    self.showAlert(title: "Success", message: "Form submitted successfuly")
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
        return form!.tasks.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath as IndexPath)
        let task = form!.tasks[indexPath.row]

        var titleText = "\(task.name)"
        if (task.result?.completed)! {
            titleText = "√ " + titleText
        }
        let requiredText = task.required ? " (required)" : ""
        cell.textLabel!.text = titleText + requiredText

        let detailText = "\(task.type)"
        cell.detailTextLabel!.text = detailText
        cell.configureDataCell()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let taskController = self.storyboard?.instantiateViewController(withIdentifier: "TaskController") as? TaskController {
            taskController.form = form
            taskController.taskIndex = indexPath.row
            let navController = UINavigationController(rootViewController: taskController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {
                
            })
        }
    }
}
