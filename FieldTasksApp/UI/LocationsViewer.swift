//
//  LocationsViewer.swift
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

    func configureWithLocation(location : FTLocation ) {
        self.makeCellFlat()
        self.title.makeTitleStyle()
        self.address.makeDetailStyle()
        self.title!.text = location.name
        self.address!.text = location.fullAddress
    }
}

class LocationsViewer: UITableViewController, LocationUpdates {
    var locations = LocationsMgr.shared
    var form : Form?
    var selectedLocation : FTLocation?
    var locationList = [FTLocation]()   // use read-only copy of live list so it's thread safe, otherwise live list could be in mid-update when we refresh
    var searchRadius = 10000000     // How far away to look for locations

    // MARK: View Methods -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        if let form = self.form {
            self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Use", target: self, action: #selector(selectionDone))
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(selectionCancel))
            selectedLocation = locations.getBy(id: form.locationId!)
            self.title = "Pick Location"
        } else {
            self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshFromServer))
            self.navigationItem.leftBarButtonItem = FlatBarButton(withImageNamed: "plus.png", target: self, action: #selector(createNewLocation))
            self.title = "Locations"
       }
        makeNavBarFlat()
        locations.delegate = self
        refreshOnMainThread()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshOnMainThread()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshOnMainThread() {
        self.locationList = self.locations.all() //self.locations.within(meters: self.searchRadius)
        if let cLoc = LocationsMgr.shared.currentCLLocation() {
            self.locationList = self.locationList.sorted { (a , b ) -> Bool in
                return a.distanceFrom(location: cLoc) < b.distanceFrom(location: cLoc)
            }
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    // In regular mode when used to display locations.
    func refreshFromServer() {
        self.locations.refresh { (error) in
            if let error = error {
                self.showAlert(title: "Error creating location", message: error)
            }
            // Refresh list data before updating visual list
            self.refreshOnMainThread()
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

    func createNewLocation() {
        self.performSegue(withIdentifier: "LocationEditor", sender: nil)
    }

    func newlocation(location: FTLocation?) {
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let location = sender as? FTLocation {
            if let locationEditor = segue.destination as? LocationEditor {
                locationEditor.location = location
            }
        }
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = locationList.count
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
            let location = locationList[indexPath.row]
            cell.configureWithLocation(location: location)
            if location.id == locations.currentLocation()?.id {
                cell.locationImage.tintColor = UIColor.silver()
                cell.locationImage.image = UIImage(named: "location.png")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.locationImage.image = nil
            }
            if location === selectedLocation {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
            }
            return cell
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locationList[indexPath.row]

        if let _ = form {
            // select location
            if let cell = tableView.cellForRow(at: indexPath) {
                selectedLocation = locationList[indexPath.row]
                cell.isSelected = true
            }
        } else {
            // Open forms for selected location
            if let templateController = self.storyboard?.instantiateViewController(withIdentifier: "TemplatesViewer") as? TemplatesViewer {
                templateController.location = location
                templateController.style = .Location
                let navController = UINavigationController(rootViewController: templateController) // Creating a navigation controller with resultController at the root of the navigation stack.
                self.present(navController, animated: true, completion: {

                })
            }
        }
    }

    // MARK: Table Editing  -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // If form, we are picker
        return self.form == nil
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.isEditing = false
            let location = self.locationList[indexPath.row]
            self.performSegue(withIdentifier: "LocationEditor", sender: location)
        }
        edit.backgroundColor = UIColor.peterRiver()

        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.isEditing = false
            self.deleteLocationFromServer(forRowAt: indexPath)
        }
        delete.backgroundColor = UIColor.alizarin()

        return [edit, delete]
    }

    func deleteLocationFromServer(forRowAt indexPath: IndexPath) {
        self.askAlert(title: "Are you sure you want to delete this location?", body: "Deletion is permanent and can't be undone", action: "Delete", completion: { (deleteIt) in
            if deleteIt {
                let location = self.locationList[indexPath.row]
                ServerMgr.shared.deleteLocation(locationId: location.id!, completion: { (error) in
                    if let error = error {
                        self.showAlert(title: "Delete failed", message: "Unable to delete location: \(error)")
                    } else {
                        CoreDataMgr.shared.deleteObject(object: location)
                        self.refreshOnMainThread()
                    }
                })
            }
        })
    }
}
