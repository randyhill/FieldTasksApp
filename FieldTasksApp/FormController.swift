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
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
     }

    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
        cell.textLabel!.text = "\(task.name)"
        cell.detailTextLabel!.text = "Type: \(task.type)"
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
