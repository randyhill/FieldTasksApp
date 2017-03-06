// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NumberTask.swift instead.

import Foundation
import CoreData

public enum NumberTaskAttributes: String {
    case isDecimal = "isDecimal"
    case isUnlimited = "isUnlimited"
    case max = "max"
    case min = "min"
}

open class _NumberTask: Task {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "NumberTask"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _NumberTask.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var isDecimal: NSNumber?

    @NSManaged open
    var isUnlimited: NSNumber?

    @NSManaged open
    var max: NSNumber?

    @NSManaged open
    var min: NSNumber?

    // MARK: - Relationships

}

