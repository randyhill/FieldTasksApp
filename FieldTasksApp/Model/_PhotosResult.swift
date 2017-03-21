// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PhotosResult.swift instead.

import Foundation
import CoreData

public enum PhotosResultAttributes: String {
    case fileNames = "fileNames"
}

open class _PhotosResult: TaskResult {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "PhotosResult"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _PhotosResult.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var fileNames: [String]?

    // MARK: - Relationships

}

