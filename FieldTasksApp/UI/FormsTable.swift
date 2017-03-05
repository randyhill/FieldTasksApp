//
//  FormsTable.swift
//  FieldTasksApp
//
//  Created by CRH on 2/20/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class SubmissionCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

class FormsTable: UITableViewController {
    var parentFormsViewer : FormsViewer?
    var formsList = [Form]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
        self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        tableView.backgroundColor = UIColor.greenSea()
    }

    func refreshList() {
        // Do any additional setup after loading the view, typically from a nib.
        // let location = parentFormsViewer?.location
        FormsMgr.shared.refreshList(location: parentFormsViewer?.location) { (forms, error) -> (Void) in
            if let error = error {
                FTAlertError(message: "Could not load forms from server: \(error)")
            } else if let forms = forms {
                self.formsList = forms
                self.reloadOnMainQueue()
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

    func reloadOnMainQueue() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formsList.count
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell", for: indexPath as IndexPath)
        if let cell = cell as? SubmissionCell {
            let form = formsList[indexPath.row]
            cell.titleLabel.text = form.name
            cell.titleLabel.makeTitleStyle()
            cell.detailLabel!.text = Globals.shared.dateFormatter.string(from: form.createDate)
            cell.detailLabel.makeDetailStyle()
            cell.makeCellFlat()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "FormViewer") as? FormViewer {
            formController.form = formsList[indexPath.row]
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {
                
            })
        }
    }
}
