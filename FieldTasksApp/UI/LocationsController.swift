//
//  LocationsController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/3/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import CoreLocation

class LocationCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
}

class LocationsController: UITableViewController, LocationUpdates {
    var locations = Locations.shared
    var form : Form?
    var selectedLocation : FTLocation?
    var list = [FTLocation]()   // use read-only copy of live list so it's thread safe, otherwise live list could be in mid-update when we refresh

    override func viewDidLoad() {
        super.viewDidLoad()

        if let form = self.form {
            self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Use", target: self, action: #selector(selectionDone))
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(selectionCancel))
            if let locationId = form.locationId {
                selectedLocation = locations.getBy(id: locationId)
            }
            self.title = "Pick Location"
        } else {
            self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshFromServer))
            self.navigationItem.leftBarButtonItem = FlatBarButton(withImageNamed: "plus.png", target: self, action: #selector(addLocation))
            self.title = "Locations"
       }
        makeNavBarFlat()
        locations.delegate = self
        self.list = locations.list.copy()
    }

    // In regular mode when used to display locations.
    func refreshFromServer() {
        self.locations.refresh { (error) in
            if let error = error {
                self.showAlert(title: "Error creating location", message: error)
            }
            // Refresh list data before updating visual list
            self.list = self.locations.list.copy()
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }

    // In modal mode when used as location picker
    func selectionCancel() {
        self.dismiss(animated: true) {}
    }

    func selectionDone() {
        if let form = self.form, let selectedLocation = self.selectedLocation {
            form.locationId = selectedLocation.id
        }
        self.dismiss(animated: true) {}
    }

    func addLocation() {
        self.performSegue(withIdentifier: "NewLocationController", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    func newlocation(location: FTLocation?) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = list.count
        return count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationsCell", for: indexPath as IndexPath)
        if let cell = cell as? LocationCell {
            let location = list[indexPath.row]
            cell.makeCellFlat()
            if location === locations.curLocation {
                cell.locationImage.tintColor = UIColor.silver()
                cell.locationImage.image = UIImage(named: "location.png")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.locationImage.image = nil
            }
            if location === selectedLocation {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
            }
            cell.title.makeTitleStyle()
            cell.address.makeDetailStyle()
            cell.title!.text = location.name
            cell.address!.text = location.fullAddress
//            cell.selectedBackgroundView?.backgroundColor = Globals.shared.selectionColor
            return cell
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = list[indexPath.row]

        if let _ = form {
            // select location
            if let cell = tableView.cellForRow(at: indexPath) {
                selectedLocation = list[indexPath.row]
                cell.isSelected = true
            }

        } else {
            // Open forms for selected location
            if let formsController = self.storyboard?.instantiateViewController(withIdentifier: "FormsController") as? FormsController {
                formsController.location = location
                let navController = UINavigationController(rootViewController: formsController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }
}
