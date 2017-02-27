//
//  FormTasksController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class FormTasksCell : UITableViewCell {
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var typeText: UILabel!
}

class FormTasksLocationCell : UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationName: UILabel!
}

class FormTasksController : UITableViewController {
    var form : Form?
    let checkmark = UIImage(named: "checkmark.png")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "New: \(form!.name)"
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Back", target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Submit", target: self, action: #selector(submitForm))
        makeNavBarFlat()
    }

    func goBack(){
        dismiss(animated: true, completion: nil)
    }

    func submitForm() {
        if let incompleteTasks = form!.tasksStillIncomplete() {
            FTAlertMessage(message: "Please complete required fields (\(incompleteTasks)) before submitting \(form!.name) form")
        } else {
            form?.submit(completion: { (error) in
                if error != nil {
                    FTAlertError(message: "Form Submission Failed: \(error!)")
                } else {
                    FTAlertSuccess(message: "Form submitted successfuly")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationPicker", let navController = segue.destination as? UINavigationController {
            if let locationsController = navController.viewControllers[0] as? LocationsController {
                locationsController.form = self.form
            }
        }
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return form!.tasks.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTasksLocationCell", for: indexPath as IndexPath)
            if let cell = cell as? FormTasksLocationCell {
                cell.locationLabel.makeTitleStyle()
                cell.locationName.makeTitleStyle()
                cell.makeCellFlat()
                // Use location from form if set, otherwise use current lcoation
                var location : FTLocation?
                if let locationId = form?.locationId {
                    location = LocationsManager.shared.getBy(id: locationId)
                }
                if location == nil {
                    location = LocationsManager.shared.currentLocation()
                }
                var locationTitle = "Unknown"
                if let location = location {
                    locationTitle = location.name
                }
                cell.locationName.text = locationTitle
            }
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTasksCell", for: indexPath as IndexPath)
            if let cell = cell as? FormTasksCell {
                let task = form!.tasks[indexPath.row]
                var titleText = task.name
                if task.required {
                    titleText += " (required)"
                }
                cell.titleText.text = titleText
                cell.titleText.makeTitleStyle()
                cell.checkmark.image = (task.result!.completed) ? checkmark : nil
                cell.typeText.text = task.type;
                cell.typeText.makeDetailStyle()
                cell.makeCellFlat()
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "LocationPicker", sender: self)
        } else {
            if let tasksController = self.storyboard?.instantiateViewController(withIdentifier: "TasksController") as? TasksController {
                tasksController.form = form
                tasksController.taskIndex = indexPath.row
                let navController = UINavigationController(rootViewController: tasksController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }
}
