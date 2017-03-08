// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChoicesResult.swift instead.

import Foundation
import CoreData

public enum ChoicesResultAttributes: String {
    case values_core = "values_core"
}

open class _ChoicesResult: TaskResult {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "ChoicesResult"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _ChoicesResult.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var values_core: AnyObject?

    // MARK: - Relationships

}

