//
//  Location.swift
//  FieldTasksApp
//
//  Created by CRH on 2/3/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import CoreLocation

class Location {
    var id = ""
    var name = ""
    var address = ""
    var address2 = ""
    var city = ""
    var state = ""
    var zip = ""
    var phone = ""
    var coordinates : CLLocation?
    var fullAddress : String {
        get {
            var addr = address
            addr += addAddressString(string: address2)
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
        if let address = locationDict["address"] as? String {
            self.address = address
        }
        if let address2 = locationDict["address2"] as? String {
            self.address2 = address2
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
            self.coordinates = CLLocation(latitude: lat, longitude: lng)
        }
    }

    init() {

    }

    func distanceFrom(location : CLLocation) -> CLLocationDistance {
        guard let locCoords = coordinates else {
            return Double.greatestFiniteMagnitude
        }
        return location.distance(from: locCoords)
    }

    func toDict() -> [String : AnyObject]{
        var taskDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        taskDict["name"] = name as AnyObject?
        taskDict["address"] = address as AnyObject?
        taskDict["address2"] = address2 as AnyObject?
        taskDict["city"] = city as AnyObject?
        taskDict["state"] = state as AnyObject?
        taskDict["zip"] = zip as AnyObject?
        return taskDict
    }
}
