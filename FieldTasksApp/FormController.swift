//
//  FormController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class FormTaskCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UITextView!
}

class FormController : UITableViewController {
    var form : Template?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = form?.name
        self.tableView.allowsSelection = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
    }

    func goBack(){
        dismiss(animated: true, completion: nil)
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
        return 80.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormTaskCell", for: indexPath as IndexPath)
        if let formTaskCell = cell as? FormTaskCell {
            let task = form!.tasks[indexPath.row]

            formTaskCell.title!.text = task.name
            if let result = task.result {
                formTaskCell.body!.text = result.description()
            } else {
                formTaskCell.body!.text = "Not entered"
            }
            formTaskCell.selectionStyle = .default
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let taskController = self.storyboard?.instantiateViewController(withIdentifier: "TaskController") as? TaskController {
            taskController.form = form
            taskController.taskIndex = indexPath.row
            taskController.isEditable = false
            let navController = UINavigationController(rootViewController: taskController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
