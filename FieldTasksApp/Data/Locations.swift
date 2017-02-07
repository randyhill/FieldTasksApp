//
//  Locations - self contained singleton to manage our lists of locations and current lcoation.
//  FieldTasksApp
//
//  Created by CRH on 2/5/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationUpdates {
    func newlocation(location : Location?)
}

class Locations : NSObject, CLLocationManagerDelegate {
    static let shared = Locations()
    var mgr = CLLocationManager()
    var list = [Location]()
    var currentLocation : Location?
    var delegate : LocationUpdates?
    var curAccuracy = CLLocationAccuracy()

    override init() {
        super.init()

        // Request access and initial location
        self.mgr.delegate = self;
        self.mgr.requestWhenInUseAuthorization()
        self.mgr.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        if newLocations.count > 0 {
            let curLocation = newLocations[0]
            curAccuracy = curLocation.horizontalAccuracy
            let atLocation = self.inLocation(to: curLocation)
            if atLocation !== currentLocation {
                currentLocation = atLocation
                delegate?.newlocation(location: currentLocation)
            }

        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func removeAll() {
        list.removeAll()
    }
    
    func add(location: Location) {
        self.list += [location]
    }

    func closestLocation(to: CLLocation) -> Location? {
        var closest : Location?
        var closestDistance = Double.greatestFiniteMagnitude
        for loc in list {
            let distance = loc.distanceFrom(location: to)
            if distance < closestDistance {
                closestDistance = distance
                closest = loc
            }
        }
        return closest
    }

    func inLocation(to: CLLocation) -> Location? {
        var closest : Location?
        var closestDistance = Double.greatestFiniteMagnitude
        for loc in list {
            let distance = loc.distanceFrom(location: to)
            if distance < closestDistance {
                closestDistance = distance
                closest = loc
            }
        }
        if (closestDistance + curAccuracy) < 100 {
            return closest
        } else {
            return nil;
        }
    }
}
