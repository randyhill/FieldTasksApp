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

class FormPhotoTaskCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!
}

class FormTitleCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UITextView!
}

class FormController : UITableViewController {
    var form : Form?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Form"
        self.tableView.allowsSelection = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        makeNavBarFlat()
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
        return form!.tasks.count + 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.0
        } else {
            return 64.0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTitleCell", for: indexPath as IndexPath)
            cell.configureHeaderCell()
            if let formTitleCell = cell as? FormTitleCell, let form = form {
                formTitleCell.title.text = "Name: " + form.name
                formTitleCell.title.makeTitleStyle()
                var locationString = "At: Unknown Location"
                if let locationId = form.locationId {
                    if let location = Locations.shared.getBy(id: locationId){
                        locationString = "Submitted At: " + location.name
                    }
                }
                var descriptionString = locationString + "\nWhen: " + Globals.shared.dateFormatter.string(from: form.createDate)
                descriptionString += "\nPurpose: " + form.description
                formTitleCell.body.text = descriptionString
                formTitleCell.body.makeDetailStyle()
                formTitleCell.body.backgroundColor = cell.contentView.backgroundColor
            }
            return cell
        } else {
            let task = form!.tasks[indexPath.row-1]
            if task.type == cFormTaskPhoto {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormPhotoTaskCell", for: indexPath as IndexPath)
                cell.makeCellFlat()
                if let formTaskCell = cell as? FormPhotoTaskCell {
                    formTaskCell.title!.text = task.name
                    formTaskCell.title.makeTitleStyle()

                    // Clear old views so we don't have old photos hanging around.
                    for oldView in formTaskCell.stackView.subviews {
                        oldView.removeFromSuperview()
                    }
                    formTaskCell.stackView.axis = .horizontal
                    formTaskCell.stackView.distribution = .fillEqually
                    if let photoResult = task.result as? PhotoResult {
                        for image in photoResult.photos {
                            let imageView = UIImageView(image: image)
                            imageView.frame = CGRect(x: 0, y: 0, width: formTaskCell.stackView.frame.height, height: formTaskCell.stackView.frame.height)
                            formTaskCell.stackView.addArrangedSubview(imageView)
                        }
                    }
                    formTaskCell.selectionStyle = .default
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormTaskCell", for: indexPath as IndexPath)
                cell.makeCellFlat()
                if let formTaskCell = cell as? FormTaskCell {

                    formTaskCell.title!.text = task.name
                    formTaskCell.title.makeTitleStyle()
                    if let result = task.result {
                        formTaskCell.body!.text = result.description()
                    } else {
                        formTaskCell.body!.text = "Not entered"
                    }
                    formTaskCell.selectionStyle = .default
                    formTaskCell.body.layer.cornerRadius = 4.0
                    formTaskCell.body.backgroundColor = Globals.shared.bgColor
                    formTaskCell.body.makeDetailStyle()
                }
                return cell
            }
         }
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 0 {
            return
        }
        if let tasksController = self.storyboard?.instantiateViewController(withIdentifier: "TasksController") as? TasksController {
            tasksController.form = form
            tasksController.taskIndex = indexPath.row - 1
            tasksController.isEditable = false
            let navController = UINavigationController(rootViewController: tasksController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
