// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetOpData.swift instead.

import Foundation
import CoreData

public enum NetOpDataAttributes: String {
    case objectName = "objectName"
    case typeName = "typeName"
}

open class _NetOpData: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "NetOpData"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _NetOpData.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var objectName: String?

    @NSManaged open
    var typeName: String?

    // MARK: - Relationships

}

