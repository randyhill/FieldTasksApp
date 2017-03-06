// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TextTask.swift instead.

import Foundation
import CoreData

public enum TextTaskAttributes: String {
    case isUnlimited = "isUnlimited"
    case max = "max"
}

open class _TextTask: Task {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TextTask"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TextTask.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var isUnlimited: NSNumber?

    @NSManaged open
    var max: NSNumber?

    // MARK: - Relationships

}

