//
//  FormTasksController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import SVProgressHUD

class FormTasksCell : UITableViewCell {

    @IBOutlet weak var checkMark: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var typeText: UILabel!
}

class FormTasksController : UITableViewController {
    var form : Form?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "New: \(form!.name)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(submitForm))
        makeNavBarFlat()
        //self.tableView.backgroundColor = Globals.shared.barColor
    }

    func goBack(){
        dismiss(animated: true, completion: nil)
    }

    func submitForm() {
        if let incompleteTasks = form!.tasksStillIncomplete() {
            SVProgressHUD.showInfo(withStatus: "Please complete required fields (\(incompleteTasks)) before submitting \(form!.name) form")
        } else {
            form?.submit(completion: { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Form Submission Failed: \(error!)")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Form submitted successfuly")
                    self.dismiss(animated: true, completion: nil)
                }
            })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormTasksCell", for: indexPath as IndexPath)
        if let cell = cell as? FormTasksCell {
            let task = form!.tasks[indexPath.row]
            var titleText = task.name
            if task.required {
                titleText += " (required)"
            }
            cell.titleText.text = titleText
            cell.titleText.makeTitleStyle()
            cell.checkMark.text = (task.result!.completed) ? "√" : ""
            cell.checkMark.makeTitleStyle()
            cell.typeText.text = task.type;
            cell.typeText.makeDetailStyle()
            cell.makeCellFlat()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let tasksController = self.storyboard?.instantiateViewController(withIdentifier: "TasksController") as? TasksController {
            tasksController.form = form
            tasksController.taskIndex = indexPath.row
            let navController = UINavigationController(rootViewController: tasksController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {
                
            })
        }
    }
}
