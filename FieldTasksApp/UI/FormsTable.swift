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
    @IBOutlet weak var locationLabel: UILabel!
}

class FormsTable: UITableViewController {
    var parentFormsViewer : FormsViewer?
    var formsList = [Form]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
        self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)
        tableView.backgroundColor = UIColor.greenSea()

        self.loadList()

        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: cFormsUpdateNotification, object: nil)
    }

    func refreshList() {
        SyncMgr.shared.sync(completion: { (syncResult) in
            if let error = syncResult.error {
                FTAlertError(message: "Could not load forms from server: \(error)")
            } else  {
                if syncResult.forms > 0 {
                    self.loadList()
                    self.reloadOnMainQueue()
                }
            }
        })
    }

    func loadList() {
        self.formsList = FormsMgr.shared.all()

        // Sort by newest
        self.formsList = self.formsList.sorted(by: { (a , b ) -> Bool in
            return a.createDate! > b.createDate!
        })
    }

    func reloadOnMainQueue() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formsList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmissionCell", for: indexPath as IndexPath)
        if let cell = cell as? SubmissionCell {
            let form = formsList[indexPath.row]
            var locationText = ""
            if let locationId = form.locationId {
                if let location = CoreDataMgr.shared.fetchById(entityName: FTLocation.entityName(), objectId: locationId) as? FTLocation, let name = location.name {
                   locationText  = name
                }
            }
            cell.locationLabel.text = locationText
            cell.locationLabel.makeDetailStyle()
            cell.titleLabel.text = form.name!
            cell.titleLabel.makeTitleStyle()
            cell.detailLabel!.text = Globals.shared.dateFormatter.string(from: form.createDate!)
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
