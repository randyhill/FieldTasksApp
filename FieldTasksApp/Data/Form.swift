//
//  Form.swift
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

class Form : Template {
    var createDate = Date()
    var locationId : String?
    var coordinates = CLLocation();

    init(formDict : [String : AnyObject]) {
        super.init(templateDict: formDict)
        if let createDate = formDict["createDate"] as? String {
            if let date = Globals.shared.utcFormatter.date(from: createDate) {
                self.createDate = date
            }
        }
        // Locations list isn't allocated yet so we can't save location here
        if let locationId = formDict["location"] as? String {
            self.locationId =  locationId
        }
    }

    override init(template: Template) {
        super.init(template: template)
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["createDate"] = Globals.shared.utcFormatter.string(from: createDate) as AnyObject?
        if let locationId = locationId {
            formDict["location"] = locationId as AnyObject;
        }
        formDict["coordinates"] = ["lat" : coordinates.coordinate.latitude, "lng" : coordinates.coordinate.longitude] as AnyObject
        return formDict
    }

    func submit(controller: UIViewController) {
        func submitForm() {
            ServerMgr.shared.saveAsForm(form: self) { (result, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Form Submission Failed: \(error!)")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Form submitted successfuly")
                }
            }
        }
        if let coordinates = Locations.shared.mgr.location {
            self.coordinates = coordinates
        }
        if let location = Locations.shared.currentLocation {
            self.locationId = location.id
        }
        let photosList = PhotoFileList(tasks: tasks)
        if photosList.count == 0 {
            submitForm()
        } else {
            // upload Photos to server first.
            ServerMgr.shared.uploadImages(photoFileList: photosList, completion: { (photoFileList, error) in
                if let _ = photoFileList {
                    // Photo file names should have been copied to photo tasks, we can submit form now
                    submitForm()
                } else {
                    SVProgressHUD.showError(withStatus: "Photos upload failed because of: \(error!)")
                }
            })
        }
    }
}