import Foundation
import CoreData

@objc(Form)
open class Form: _Form {
    func initFromTemplate(context: NSManagedObjectContext, template: Template) {
        let templateDict = template.toDict()
        self.fromDict(context: context, formDict: templateDict)
        self.id = ""
        self.templateId = template.id
    }

    func fromDict(context: NSManagedObjectContext,formDict: [String : Any]) {
        super.fromDict(context: context, templateDict: formDict)

        if let auditTrail = formDict["auditTrail"] as? [String: Any] {
            if let createDate = auditTrail["created"] as? String {
                self.createDate = Globals.shared.utcFormatter.date(from: createDate)
            }
        }
        // Locations list isn't allocated yet so we can't save location here
        self.locationId = formDict["location"] as? String ?? ""
        self.latitude = formDict["latitude"] as? NSNumber ?? 0
        self.longitude = formDict["longitude"] as? NSNumber ?? 0
        if let submissionString = formDict["submitted"] as? String {
            self.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
        }

        // Locations list isn't allocated yet so we can't save location here
        FTAssert(exists: createDate, error: "createDate doesn't exist")
    }

    override func toDict() -> [String : AnyObject] {
        var formDict = super.toDict()
        formDict["created"] = Globals.shared.utcFormatter.string(from: createDate!) as AnyObject?
        formDict["location"] = locationId as AnyObject
        formDict["latitude"] = self.latitude
        formDict["longitude"] = self.longitude
        formDict["templateId"] = self.templateId as AnyObject?
        return formDict
    }

//    func submitForm(completion : @escaping (_ error: String?)->()) {
//        ServerMgr.shared.saveAsForm(form: self) { (result, error) in
//            if error != nil {
//                completion(error)
//            } else {
//                //  update id
//                if let formDict = result, let formId = formDict["_id"] as? String {
//                    self.id = formId
//                    if let submissionString = formDict["submitted"] as? String {
//                        self.submitted = Globals.shared.utcFormatter.date(from: submissionString)  // Server sets submission date so we know was successful
//                    }
//                    completion(nil)
//                } else {
//                    completion("couldn't update form id")
//                }
//            }
//        }
//    }

    func submit() {
        NetOpsQueueMgr.shared.submitFormWithPhotos(form: self)
    }
//    func submit(completion : @escaping (_ error: String?)->()) {
//        if let coordinates = LocationsMgr.shared.currentCoordinates() {
//            self.latitude = coordinates.latitude as NSNumber?
//            self.longitude = coordinates.longitude as NSNumber?
//        }
//        let photosList = PhotoFileList(tasks: tasks , buildWithImages: true)
//        if photosList.count == 0 {
//            submitForm(completion: completion)
//        } else {
//            NetOpsQueueMgr.shared.uploadImages(form: self, photoFileList: photosList)
//            completion(nil)
            // upload Photos to server first.
//            ServerMgr.shared.uploadImages(photoFileList: photosList, completion: { (photoFileList, error) in
//                if let _ = photoFileList {
//                    // Photo file names should have been copied to photo tasks, we can submit form now
//                    self.submitForm(completion: completion)
//                } else {
//                    completion("Photos upload failed because of: \(error!)")
//                }
//            })
 //       }
 //   }	// Custom logic goes here.
}
