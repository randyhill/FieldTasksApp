// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Form.swift instead.

import Foundation
import CoreData

public enum FormAttributes: String {
    case createDate = "createDate"
    case latitude = "latitude"
    case locationId = "locationId"
    case longitude = "longitude"
    case submitted = "submitted"
    case templateId = "templateId"
}

open class _Form: Template {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "Form"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Form.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var createDate: Date?

    @NSManaged open
    var latitude: NSNumber?

    @NSManaged open
    var locationId: String?

    @NSManaged open
    var longitude: NSNumber?

    @NSManaged open
    var submitted: Date?

    @NSManaged open
    var templateId: String?

    // MARK: - Relationships

}

