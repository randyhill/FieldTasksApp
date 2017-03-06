// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NumberResult.swift instead.

import Foundation
import CoreData

public enum NumberResultAttributes: String {
    case value = "value"
}

open class _NumberResult: TaskResult {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "NumberResult"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _NumberResult.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var value: NSNumber?

    // MARK: - Relationships

}

