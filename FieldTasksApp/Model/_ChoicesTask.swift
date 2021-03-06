// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChoicesTask.swift instead.

import Foundation
import CoreData

public enum ChoicesTaskAttributes: String {
    case hasOther = "hasOther"
    case isRadio = "isRadio"
    case titles = "titles"
}

open class _ChoicesTask: Task {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "ChoicesTask"
    }

    override open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _ChoicesTask.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var hasOther: NSNumber?

    @NSManaged open
    var isRadio: NSNumber?

    @NSManaged open
    var titles: [String]?

    // MARK: - Relationships

}

