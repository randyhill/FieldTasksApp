//
//  FormViewer.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

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

class FormViewer : UITableViewController {
    var form : Form?

    override func viewDidLoad() {
        super.viewDidLoad()

        FTAssert(isTrue: form != nil, error: "Form was not set before opening view")
        self.title = form?.name ?? "Form"
        self.tableView.allowsSelection = true
        navigationItem.leftBarButtonItem = FlatBarButton(title: "Back", target: self, action: #selector(goBack))
        makeNavBarFlat()
    }

    func goBack(){
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        let photosList = PhotoFileList(tasks: form!.tasks, buildWithImages: false)
        ServerMgr.shared.downloadFiles(photoFileList: photosList, imageUpdate: { (index) in
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: index + 1, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        }, completion: { (error) in
            if let error = error {
                FTErrorMessage(error: "Could not download all photos: \(error)")
            }
        })
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
                var locationString = "Location: Unknown"
                if let locationId = form.locationId {
                    if let location = LocationsMgr.shared.getBy(id: locationId){
                        locationString = "For: " + location.name
                    }
                }
                formTitleCell.title.text = locationString
                formTitleCell.title.makeTitleStyle()

                let coordinatesString = "lat: \(form.coordinates?.latitude) long: \(form.coordinates?.longitude)"
                var descriptionString = Globals.shared.dateFormatter.string(from: form.createDate) + " " + coordinatesString
                descriptionString += "\n" + form.description
                formTitleCell.body.text = descriptionString
                formTitleCell.body.makeDetailStyle()
                formTitleCell.body.backgroundColor = cell.contentView.backgroundColor
                formTitleCell.selectionStyle = .none
           }
            return cell
        } else {
            let task = form!.tasks[indexPath.row-1]
            if task.type == TaskType.Photos {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormPhotoTaskCell", for: indexPath as IndexPath)
                cell.makeCellFlat()
                if let taskCell = cell as? FormPhotoTaskCell {
                    taskCell.title!.text = task.name
                    taskCell.title.makeTitleStyle()

                    // Clear old views so we don't have old photos hanging around.
                    for oldView in taskCell.stackView.subviews {
                        oldView.removeFromSuperview()
                    }
                    if let photoResult = task.result as? PhotoResult {
                        for image in photoResult.photos {
                            let imageView = UIImageView(image: image)
                            imageView.contentMode = .scaleAspectFit
                            imageView.translatesAutoresizingMaskIntoConstraints = false
                            taskCell.stackView.addArrangedSubview(imageView)
                        }
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormTaskCell", for: indexPath as IndexPath)
                cell.makeCellFlat()
                if let taskCell = cell as? FormTaskCell {

                    taskCell.title!.text = task.name
                    taskCell.title.makeTitleStyle()
                    if let result = task.result {
                        taskCell.body!.text = result.description()
                    } else {
                        taskCell.body!.text = "Not entered"
                    }
                    taskCell.selectionStyle = .default
                    taskCell.body.layer.cornerRadius = 4.0
                    taskCell.body.backgroundColor = Globals.shared.bgColor
                    taskCell.body.makeDetailStyle()
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
        if let tasksController = self.storyboard?.instantiateViewController(withIdentifier: "TasksViewer") as? TasksViewer {
            tasksController.form = form
            tasksController.taskIndex = indexPath.row - 1
            tasksController.isEditable = false
            let navController = UINavigationController(rootViewController: tasksController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
