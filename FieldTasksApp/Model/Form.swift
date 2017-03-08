import Foundation

@objc(Form)
open class Form: _Form {
    override func initFromTemplate(template: Template) {
        super.initFromTemplate(template: template)
        templateId = template.id
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
        if let latitude = templateDict["latitude"] as? Double {
            self.latitude =  latitude as NSNumber?
        }
        if let longitude = templateDict["longitude"] as? Double {
            self.longitude =  longitude as NSNumber?
        }
        FTAssert(exists: latitude, error: "Latitude doesn't exist")
        FTAssert(exists: longitude, error: "longitude doesn't exist")
        FTAssert(exists: createDate, error: "createDate doesn't exist")
        FTAssert(exists: locationId, error: "locationId doesn't exist")
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["createDate"] = Globals.shared.utcFormatter.string(from: createDate!) as AnyObject?
        formDict["location"] = locationId as AnyObject
        formDict["latitude"] = self.latitude
        formDict["longitude"] = self.longitude
        return formDict
    }

    func submitForm(completion : @escaping (_ error: String?)->()) {
        ServerMgr.shared.saveAsForm(form: self) { (result, error) in
            if error != nil {
                completion(error)
            } else {
                // should update id
                if let formDict = result, let formId = formDict["_id"] as? String {
                    self.id = formId
                    FormsMgr.shared.formSubmitted(form: self)
                    completion(nil)
                } else {
                    completion("couldn't update form id")
                }
            }
        }
    }

    func submit(completion : @escaping (_ error: String?)->()) {
        if let coordinates = LocationsMgr.shared.currentCoordinates() {
            self.latitude = coordinates.latitude as NSNumber?
            self.longitude = coordinates.longitude as NSNumber?
        }
        let photosList = PhotoFileList(tasks: tasks , buildWithImages: true)
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
    }	// Custom logic goes here.
}
