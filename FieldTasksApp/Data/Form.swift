//
//  Form.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import CoreLocation

class Form : Template {
    var createDate = Date()
    var locationId : String?
    var coordinates : CLLocationCoordinate2D?

    // init from dict
    override init(templateDict : [String : Any]) {
        super.init(templateDict: templateDict)
    }

    override init(template: Template) {
        super.init(template: template)
    }

    override func fromDict(templateDict: [String : Any]) {
        super.fromDict(templateDict: templateDict)
        if let createDate = templateDict["createDate"] as? String {
            if let date = Globals.shared.utcFormatter.date(from: createDate) {
                self.createDate = date
            }
        }
        // Locations list isn't allocated yet so we can't save location here
        if let locationId = templateDict["location"] as? String {
            self.locationId =  locationId
        }
        // Locations list isn't allocated yet so we can't save location here
        if let locationId = templateDict["coordinates"] as? String {
            self.locationId =  locationId
        }
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["createDate"] = Globals.shared.utcFormatter.string(from: createDate) as AnyObject?
        if let locationId = locationId {
            formDict["location"] = locationId as AnyObject;
        }
        if let coordinate = coordinates {
            formDict["coordinates"] = ["lat" : coordinate.latitude, "lng" : coordinate.longitude] as AnyObject
        }
        return formDict
    }

    func submitForm(completion : @escaping (_ error: String?)->()) {
        ServerMgr.shared.saveAsForm(form: self) { (result, error) in
            if error != nil {
                completion(error)
            } else {
                // shouldn't we update id?
                completion(nil)
            }
        }
    }

    func submit(completion : @escaping (_ error: String?)->()) {
        if let coordinates = LocationsMgr.shared.currentCoordinates() {
            self.coordinates = coordinates
        }
        let photosList = PhotoFileList(tasks: tasks, buildWithImages: true)
        if photosList.count == 0 {
            submitForm(completion: completion)
        } else {
            // upload Photos to server first.
            ServerMgr.shared.uploadImages(photoFileList: photosList, completion: { (photoFileList, error) in
                if let _ = photoFileList {
                    // Photo file names should have been copied to photo tasks, we can submit form now
                    self.submitForm(completion: completion)
                } else {
                    completion("Photos upload failed because of: \(error!)")
                }
            })
        }
    }
}
