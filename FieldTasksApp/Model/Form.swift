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

    func submit() {
        NetworkOpsMgr.shared.submitForm(form: self)
    }
}
