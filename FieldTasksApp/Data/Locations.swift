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
        self.refresh(completion: { (error) in
            FTErrorMessage(error: "unable to load locations at initialize: \(error)")
        })
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
        FTErrorMessage(error: error.localizedDescription)
    }

    func refresh(completion: @escaping (_ error: String?)->()) {
        self.mgr.requestLocation()
        ServerMgr.shared.loadLocations { (result, error) in
            if error != nil {
                completion(error)
            } else if let newList = result  {
                self.list.removeAll()
                for location in newList {
                    if let locationDict = location as? [String : AnyObject] {
                        do {
                            let location = try Location(locationDict: locationDict)
                            self.list += [location]
                        } catch FTError.RunTimeError(let errorMessage) {
                            completion(errorMessage)
                         } catch {
                             completion(error.localizedDescription)
                       }
                    }
                }
                self.sort()
                completion(nil)
            }
        }
    }

    // Resort to put current location at top.
    func sort() {
        if let currentLoc = currentLocation {
            var newList = [Location]()
            newList += [currentLoc]
            for location in list {
                if location.id != currentLoc.id {
                    newList += [location]
                }
            }
            self.list = newList
        }
    }

    func removeAll() {
        list.removeAll()
    }

    func getBy(id: String) -> Location? {
        for location in list {
            if location.id == id {
                return location
            }
        }
        return nil
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
