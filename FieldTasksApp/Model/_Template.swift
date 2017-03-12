// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Template.swift instead.

import Foundation
import CoreData

public enum TemplateAttributes: String {
    case descriptionString = "descriptionString"
    case id = "id"
    case name = "name"
}

public enum TemplateRelationships: String {
    case taskSet = "taskSet"
}

open class _Template: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Template"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Template.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var descriptionString: String?

    @NSManaged open
    var id: String?

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var taskSet: NSOrderedSet

    open func taskSetSet() -> NSMutableOrderedSet {
        return self.taskSet.mutableCopy() as! NSMutableOrderedSet
    }

}

extension _Template {

    open func addTaskSet(_ objects: NSOrderedSet) {
        let mutable = self.taskSet.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.taskSet = mutable.copy() as! NSOrderedSet
    }

    open func removeTaskSet(_ objects: NSOrderedSet) {
        let mutable = self.taskSet.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.taskSet = mutable.copy() as! NSOrderedSet
    }

    open func addTaskSetObject(_ value: Task) {
        let mutable = self.taskSet.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.taskSet = mutable.copy() as! NSOrderedSet
    }

    open func removeTaskSetObject(_ value: Task) {
        let mutable = self.taskSet.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.taskSet = mutable.copy() as! NSOrderedSet
    }

}

