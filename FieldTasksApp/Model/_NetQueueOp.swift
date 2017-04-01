// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetQueueOp.swift instead.

import Foundation
import CoreData

public enum NetQueueOpAttributes: String {
    case objectKey = "objectKey"
    case typeName = "typeName"
}

public enum NetQueueOpRelationships: String {
    case list = "list"
}

open class _NetQueueOp: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "NetQueueOp"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _NetQueueOp.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var objectKey: String?

    @NSManaged open
    var typeName: String?

    // MARK: - Relationships

    @NSManaged open
    var list: NetOpsQueue?

}

