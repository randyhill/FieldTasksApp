// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileName.swift instead.

import Foundation
import CoreData

public enum FileNameAttributes: String {
    case name = "name"
}

open class _FileName: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "FileName"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _FileName.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String?

    // MARK: - Relationships

}

