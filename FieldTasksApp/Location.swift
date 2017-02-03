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

    init(locationDict : [String : AnyObject]) {
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
        if let coordinates = locationDict["coordinates"] as? String {
            //self.zip = zip
        }
        if let id = locationDict["_id"] as? String {
            self.id = id
        }
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
