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

struct SortedLocation {
    var location : FTLocation?
    var distance = 0
}

class LocationsMgr : NSObject, CLLocationManagerDelegate {
    static let shared = LocationsMgr()
    private var mgr = CLLocationManager()
    private var curLocation : FTLocation?
    var delegate : LocationUpdates?
    var curAccuracy = CLLocationAccuracy()
    var lastSync : Date?
    let cSyncValue = "LocationsSync"

    override init() {
        super.init()

        // Request access and initial location
        self.mgr.delegate = self;
        self.mgr.requestWhenInUseAuthorization()
        self.lastSync = Globals.getSettingsValue(key: cSyncValue) as? Date ?? Globals.shared.stringToDate(dateString: "2017-01-01")
        self.mgr.requestLocation()
    }

    // MARK: CLLocation Methods -------------------------------------------------------------------------------
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        if newLocations.count > 0 {
            let firstCLoc = newLocations[0]
            curAccuracy = firstCLoc.horizontalAccuracy
            let atLocation = self.inLocation(to: firstCLoc)
            if atLocation == nil && curLocation == nil {
                return
            } else if atLocation == nil || curLocation == nil {
                curLocation = atLocation
                delegate?.newlocation(location: curLocation)
            } else if let atLoc = atLocation, let curLoc = curLocation {
                if atLoc.id != curLoc.id {
                    curLocation = atLoc
                    delegate?.newlocation(location: curLocation)
                }
            }
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        FTErrorMessage(error: error.localizedDescription)
    }

    // Sync refresh, get all location changes since last location sync.
    // - Update any existing locations that have changed
    // - Add new locations
    // - Delete any locations that have their delete flag set
    func refresh(completion: @escaping (_ error: String?)->()) {
        self.mgr.requestLocation()
        ServerMgr.shared.syncLocations(sinceDate: self.lastSync!, completion: { (result, timeStamp, error) in
            if error != nil {
                completion(error)
            } else if let newList = result  {
                let error = SyncLocations.syncList(newList: newList)
                self.lastSync = timeStamp
                Globals.saveSettingsValue(key: self.cSyncValue, value: self.lastSync as AnyObject)
                CoreDataMgr.shared.save()
                completion(error)
            }
        })
    }


    func currentCLLocation() -> CLLocation? {
        return mgr.location
    }

    func currentCoordinates() -> CLLocationCoordinate2D? {
        return mgr.location?.coordinate
        //return curLocation?.coordinates()
    }

    // MARK: FTLocation Methods -------------------------------------------------------------------------------

    func all() -> [FTLocation] {
        if let list = CoreDataMgr.shared.fetchLocations() {
            return list
        }
        return [FTLocation]()
    }


    // Return locations within meters sorted by closest
    func within(meters : Int) -> [FTLocation] {
        var newList = [FTLocation]()
        if let cLoc = mgr.location {
            var sorted = [SortedLocation]()
            for location in self.all() {
                let meters = location.distanceFrom(location: cLoc)
                sorted += [SortedLocation(location: location, distance: Int(meters))]
            }
            sorted.sort {
                return $0.distance < $1.distance
            }
            let filtered = sorted.filter({ (s) -> Bool in
                return s.distance < meters
            })
            newList = filtered.map({ (s) -> FTLocation in
                return s.location!
            })
        }
        return newList
    }

    func getBy(id: String) -> FTLocation? {
        for location in self.all() {
            if location.id == id {
                return location
            }
        }
        return nil
    }

    func closestLocation() -> FTLocation? {
        if let to = mgr.location {
            var closest : FTLocation?
            var closestDistance = Double.greatestFiniteMagnitude
            for loc in self.all() {
                let distance = loc.distanceFrom(location: to)
                if distance < closestDistance {
                    closestDistance = distance
                    closest = loc
                }
            }
            return closest
        }
        return nil
     }

    func inLocation(to: CLLocation) -> FTLocation? {
        for loc in self.all() {
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

    // MARK: Address Methods -------------------------------------------------------------------------------
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
}
