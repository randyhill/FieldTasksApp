import Foundation
import CoreLocation

@objc(FTLocation)
open class FTLocation: _FTLocation {
    private var templates = Set<String>()

    var fullAddress : String {
        get {
            var addr = street!
            addr += addAddressString(string: city!)
            addr += addAddressString(string: state!)
            addr += addAddressString(string: zip!)
            return addr
        }
    }

    private func addAddressString(string : String) -> String {
        if string.characters.count > 0 {
            return ", " + string
        }
        return ""
    }

    // MARK: Initialization/Serialization -------------------------------------------------------------------------------

    func fromDict(locationDict : [String : AnyObject]) {
        self.id = locationDict["_id"] as? String ?? ""
        self.name = locationDict["name"] as? String ?? ""
        self.street = locationDict["street"] as? String ?? ""
        self.city = locationDict["city"] as? String ?? ""
        self.state = locationDict["state"] as? String ?? ""
        self.zip = locationDict["zip"] as? String ?? ""
        self.latitude = locationDict["latitude"] as? NSNumber ?? 0
        self.longitude = locationDict["longitude"] as? NSNumber ?? 100
        self.perimeter = locationDict["perimeter"] as? NSNumber ?? 0

        if let templatesArray = locationDict["templates"] as? [String] {
            for templateId in templatesArray {
                self.templates.insert(templateId)
            }
        }
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
        taskDict["latitude"] = latitude as AnyObject?
        taskDict["longitude"] = longitude as AnyObject?
        taskDict["templates"] = templateIds() as AnyObject?
        return taskDict
    }

    // MARK: Templates -------------------------------------------------------------------------------
    func addTemplates(newTemplates : [Template]) {
        for template in newTemplates {
            templates.insert(template.id!)
        }
    }

    func removeTemplate(templateId : String) {
        templates.remove(templateId)
    }

    func templateIds() -> [String] {
        return Array(templates)
    }

    func containsTemplate(templateId: String) -> Bool {
        return templates.contains(templateId)
    }

    // MARK: Location Utilities -------------------------------------------------------------------------------
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

    func coordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (latitude as Double?)!, longitude: (longitude as Double?)!)
    }

    func fromCLLocation(clLoc : CLLocation) {
        latitude = clLoc.coordinate.latitude as NSNumber?
        longitude = clLoc.coordinate.longitude as NSNumber?
    }

    func distanceFrom(location : CLLocation) -> CLLocationDistance {
        guard let latitude = latitude, let longitude = longitude else {
            return Double.greatestFiniteMagnitude
        }
        let ourLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        return location.distance(from: ourLocation)
    }

    func inLocation(location : CLLocation) -> Bool {
        guard let latitude = latitude, let longitude = longitude else {
            return false
        }
        let ourLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let distance = Int(location.distance(from: ourLocation))
        return distance <= self.perimeter!.intValue
    }
}
