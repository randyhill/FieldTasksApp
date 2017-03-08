// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FTLocation.swift instead.

import Foundation
import CoreData

public enum FTLocationAttributes: String {
    case city = "city"
    case id = "id"
    case latitude = "latitude"
    case longitude = "longitude"
    case name = "name"
    case perimeter = "perimeter"
    case phone = "phone"
    case state = "state"
    case street = "street"
    case template_ids = "template_ids"
    case zip = "zip"
}

open class _FTLocation: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "FTLocation"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _FTLocation.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var city: String?

    @NSManaged open
    var id: String?

    @NSManaged open
    var latitude: NSNumber?

    @NSManaged open
    var longitude: NSNumber?

    @NSManaged open
    var name: String?

    @NSManaged open
    var perimeter: NSNumber?

    @NSManaged open
    var phone: String?

    @NSManaged open
    var state: String?

    @NSManaged open
    var street: String?

    @NSManaged open
    var template_ids: AnyObject?

    @NSManaged open
    var zip: String?

    // MARK: - Relationships

}

