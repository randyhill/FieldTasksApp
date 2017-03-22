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

    func configureWithTask(task: Task) {
        self.makeCellFlat()
        self.title!.text = task.name
        self.title.makeTitleStyle()
        if let result = task.result {
            self.body!.text = result.resultString()
        } else {
            self.body!.text = "Not entered"
        }
        self.selectionStyle = .default
        self.body.layer.cornerRadius = 4.0
        self.body.backgroundColor = Globals.shared.bgColor
        self.body.makeDetailStyle()
    }
}

class FormPhotoTaskCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    func configureWithPhotosTask(task : Task) {
        self.makeCellFlat()
        self.title!.text = task.name
        self.title.makeTitleStyle()

        // Clear old views so we don't have old photos hanging around.
        for oldView in self.stackView.subviews {
            oldView.removeFromSuperview()
        }
        if let photoResult = task.result as? PhotosResult {
            for i in 0..<photoResult.count() {
                if let image = photoResult.at(index: i) {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    self.stackView.addArrangedSubview(imageView)
                }
            }
        }
    }
}

class FormTitleCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UITextView!

    func configureWithForm(form : Form) {
        var locationString = "Location: Unknown"
        if let location = LocationsMgr.shared.getBy(id: form.locationId!){
            locationString = "For: " + location.name!
        }
        self.title.text = locationString
        self.title.makeTitleStyle()

        let coordinatesString = "lat: \(form.latitude) long: \(form.longitude)"
        var descriptionString = Globals.shared.dateFormatter.string(from: form.createDate!) + " " + coordinatesString
        descriptionString += "\n" + (form.descriptionString ?? "")
        self.body.text = descriptionString
        self.body.makeDetailStyle()
        self.body.backgroundColor = self.contentView.backgroundColor
        self.selectionStyle = .none
    }
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

        var rowIndex = 0
        for task in form!.tasks {
            if let task = task as? PhotosTask {
                if let result = task.result as? PhotosResult {
                    result.loadAll(imageLoaded: { (image) in
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    })
                }
            }
            rowIndex += 1
        }
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
                formTitleCell.configureWithForm(form: form)
           }
            return cell
        } else {
            let task = form!.tasks[indexPath.row-1]
            if task.type == TaskType.Photos.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormPhotoTaskCell", for: indexPath as IndexPath)
                if let taskCell = cell as? FormPhotoTaskCell {
                    taskCell.configureWithPhotosTask(task: task)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FormTaskCell", for: indexPath as IndexPath)
                if let taskCell = cell as? FormTaskCell {
                    taskCell.configureWithTask(task: task)
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
