// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TextResult.swift instead.

import Foundation
import CoreData

public enum TextResultAttributes: String {
    case text = "text"
}

open class _TextResult: TaskResult {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TextResult"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TextResult.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var text: String

    // MARK: - Relationships

}

