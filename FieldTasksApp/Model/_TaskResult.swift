// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TaskResult.swift instead.

import Foundation
import CoreData

public enum TaskResultAttributes: String {
    case completed_private = "completed_private"
}

public enum TaskResultRelationships: String {
    case task = "task"
}

open class _TaskResult: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "TaskResult"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TaskResult.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var completed_private: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var task: Task?

}

