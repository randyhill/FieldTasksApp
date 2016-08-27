//
//  FormController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class FormController : UITableViewController {
    var form : Form?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Form: \(form!.name)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(submitForm))
    }

    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    func submitForm() {
        if !form!.isComplete() {
            self.showAlert("Form Incomplete", message: "You must complete all required fields before submitting the form")
        } else {
            ServerManager.sharedInstance.saveForm(form!) { (result, error) in
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form!.tasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath)
        let task = form!.tasks[indexPath.row]

        var titleText = "\(task.name)"
        if (task.result?.completed)! {
            titleText = "√ " + titleText
        }
        cell.textLabel!.text = titleText

        let detailText = "\(task.type)"
        cell.detailTextLabel!.text = detailText
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let taskController = self.storyboard?.instantiateViewControllerWithIdentifier("TaskController") as? TaskController {
            taskController.form = form
            taskController.taskIndex = indexPath.row
            let navController = UINavigationController(rootViewController: taskController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.presentViewController(navController, animated: true, completion: {

            })
        }
    }
}
