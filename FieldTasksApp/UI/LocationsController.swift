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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Locations"
        self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshFromServer))
        self.navigationItem.leftBarButtonItem = FlatBarButton(withImageNamed: "plus.png", target: self, action: #selector(addLocation))
        makeNavBarFlat()
        locations.delegate = self
    }

    func refreshFromServer() {
        self.locations.refresh { (error) in
            if let error = error {
                self.showAlert(title: "Error creating location", message: error)
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }

    func addLocation() {
        self.performSegue(withIdentifier: "NewLocationController", sender: self)
//        if let _ = Locations.shared.inLocation() {
//            self.performSegue(withIdentifier: "NewLocationController", sender: self)
//        } else {
//            FTAlertMessage(message: "You are in a saved location already, you can't create a duplicate of it")
//        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    func newlocation(location: FTLocation?) {
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refreshFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table Methods -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.list.count
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

            let location = locations.list[indexPath.row]
            cell.makeCellFlat()
            if location === locations.currentLocation {
                cell.locationImage.tintColor = UIColor.silver()
                cell.locationImage.image = UIImage(named: "location.png")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.locationImage.image = nil
            }
            cell.title.makeTitleStyle()
            cell.address.makeDetailStyle()
            cell.title!.text = location.name
            cell.address!.text = location.fullAddress
            return cell
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations.list[indexPath.row]
        if let formsController = self.storyboard?.instantiateViewController(withIdentifier: "FormsController") as? FormsController {
            formsController.location = location
            let navController = UINavigationController(rootViewController: formsController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}
