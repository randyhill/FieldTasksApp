// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Task.swift instead.

import Foundation
import CoreData

public enum TaskAttributes: String {
    case descriptionString = "descriptionString"
    case id = "id"
    case name = "name"
    case required = "required"
    case type = "type"
}

public enum TaskRelationships: String {
    case result = "result"
}

open class _Task: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Task"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Task.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var descriptionString: String

    @NSManaged open
    var id: String

    @NSManaged open
    var name: String

    @NSManaged open
    var required: NSNumber?

    @NSManaged open
    var type: String

    // MARK: - Relationships

    @NSManaged open
    var result: TaskResult?

}

