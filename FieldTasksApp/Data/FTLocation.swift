//
//  Location.swift
//  FieldTasksApp
//
//  Created by CRH on 2/3/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import CoreLocation

class FTLocation {
    var id = ""
    var name = ""
    var street = ""
    var city = ""
    var state = ""
    var zip = ""
    var phone = ""
    var coordinates : CLLocationCoordinate2D?
    var perimeter = 100
    var fullAddress : String {
        get {
            var addr = street
            addr += addAddressString(string: city)
            addr += addAddressString(string: state)
            addr += addAddressString(string: zip)
            return addr
        }
    }

    private func addAddressString(string : String) -> String {
        if string.characters.count > 0 {
            return ", " + string
        }
        return ""
    }

    init(locationDict : [String : AnyObject]) throws {
        if let name = locationDict["name"] as? String {
            self.name = name
        }
        if let street = locationDict["street"] as? String {
            self.street = street
        }
        if let city = locationDict["city"] as? String {
            self.city = city
        }
        if let state = locationDict["state"] as? String {
            self.state = state
        }
        if let zip = locationDict["zip"] as? String {
            self.zip = zip
        }
        if let perimeter = locationDict["perimeter"] as? Int {
            self.perimeter = perimeter
        }
        if let id = locationDict["_id"] as? String {
            self.id = id
        }
        if let coordinateDict = locationDict["coordinates"] {
            guard let latString = coordinateDict["lat"] as? String, let lat = Double(latString) else {
                throw FTError.RunTimeError("Could not convert latitude to double")
            }
            guard let lngString = coordinateDict["lng"] as? String, let lng = Double(lngString) else {
                throw FTError.RunTimeError("Could not convert longitude to double")
            }
            self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }

    init() {

    }

    func updateFromPlacemarkDict(locationDict: [AnyHashable : Any]) {
        self.street = locationDict["Street"] as? String ?? ""
        self.city = locationDict["City"] as? String ?? ""
        self.state = locationDict["State"] as? String ?? ""
        self.zip = locationDict["Zip"] as? String ?? ""
    }

    func toPlacemarkDict() -> [AnyHashable : Any] {
        var locationDict = [AnyHashable : Any]()
        locationDict["Name"] = self.name
        locationDict["Street"] = self.street
        locationDict["City"] = self.city
        locationDict["State"] = self.state
        locationDict["Zip"] = self.zip
        return locationDict
    }

    func toCLLocation(completion: @escaping (_ location: CLLocation)->()) {
        let coder = CLGeocoder()
        coder.geocodeAddressDictionary(self.toPlacemarkDict()) { (placeMarks, err) in
            if let err = err as? String {
                FTErrorMessage(error: err)
            } else {
                if let location = placeMarks?[0].location {
                    completion(location)
                }
            }
        }
    }

    func fromCLLocation(clLoc : CLLocation) {
        coordinates = clLoc.coordinate
    }

    func distanceFrom(location : CLLocation) -> CLLocationDistance {
        guard let locCoords = coordinates else {
            return Double.greatestFiniteMagnitude
        }
        let ourLocation = CLLocation(latitude: locCoords.latitude, longitude: locCoords.longitude)
        return location.distance(from: ourLocation)
    }

    func inLocation(location : CLLocation) -> Bool {
        guard let locCoords = coordinates else {
            return false
        }
        let ourLocation = CLLocation(latitude: locCoords.latitude, longitude: locCoords.longitude)
        let distance = Int(location.distance(from: ourLocation))
        return distance <= self.perimeter
    }

    func toDict() -> [String : AnyObject]{
        var taskDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        taskDict["name"] = name as AnyObject?
        taskDict["street"] = street as AnyObject?
        taskDict["city"] = city as AnyObject?
        taskDict["state"] = state as AnyObject?
        taskDict["zip"] = zip as AnyObject?
        taskDict["perimeter"] = perimeter as AnyObject?
        if let coordinate = coordinates {
            let coordinateDict = ["lat" : String(coordinate.latitude), "lng": String(coordinate.longitude)]
            taskDict["coordinates"] = coordinateDict as AnyObject?
        }
        return taskDict
    }
}