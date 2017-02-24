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
    func newlocation(location : FTLocation?)
}

class Locations : NSObject, CLLocationManagerDelegate {
    static let shared = Locations()
    private var mgr = CLLocationManager()
    var list = SynchronizedArray<FTLocation>()
    var curLocation : FTLocation?
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
            let firstCLoc = newLocations[0]
            curAccuracy = firstCLoc.horizontalAccuracy
            let atLocation = self.inLocation(to: firstCLoc)
            if atLocation == nil && curLocation == nil {
                return
            } else if atLocation == nil || curLocation == nil {
                curLocation = atLocation
                delegate?.newlocation(location: curLocation)
                self.sort()
            } else if let atLoc = atLocation, let curLoc = curLocation {
                if atLoc.id != curLoc.id {
                    curLocation = atLoc
                    delegate?.newlocation(location: curLocation)
                    self.sort()
                }
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
                            let location = try FTLocation(locationDict: locationDict)
                            self.list.append(newElement: location)
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
        if let currentLoc = curLocation {
            var newList = [FTLocation]()
            newList += [currentLoc]
            for location in list {
                if location.id != currentLoc.id {
                    newList += [location]
                }
            }
            self.list.replace(newArray: newList)
        }
    }

    func removeAll() {
        list.removeAll()
    }

    func getBy(id: String) -> FTLocation? {
        for location in list {
            if location.id == id {
                return location
            }
        }
        return nil
    }

    func closestLocation(to: CLLocation) -> FTLocation? {
        var closest : FTLocation?
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

    func inLocation(to: CLLocation) -> FTLocation? {
        for loc in list {
            if loc.inLocation(location: to) {
                return loc
            }
        }
        return nil
    }

    func currentLocation() -> FTLocation? {
        if let cloc = mgr.location {
            return inLocation(to: cloc)
        }
        return nil
    }

    func currentAddress(completion: @escaping (_ locationDict: [AnyHashable : Any])->()) {
        if let location = mgr.location {
            clLocationToAddress(location: location, completion: completion)
        }
    }

    func coordinatesToAddress(coordinates: CLLocationCoordinate2D, completion: @escaping (_ locationDict: [AnyHashable : Any])->()) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        clLocationToAddress(location: location, completion: completion)
    }

    func clLocationToAddress(location: CLLocation, completion: @escaping (_ locationDict: [AnyHashable : Any])->()) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, err) in
            if err != nil {
                FTErrorMessage(error: "Failed to get address: \(err)")
            } else if let locationDict = placemarks?[0].addressDictionary {
                completion(locationDict)
            }
        })
    }


    func currentCLLocation() -> CLLocation? {
        return mgr.location
    }
}
