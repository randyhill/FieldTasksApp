// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetOpsQueue.swift instead.

import Foundation
import CoreData

public enum NetOpsQueueAttributes: String {
    case name = "name"
}

public enum NetOpsQueueRelationships: String {
    case relationship = "relationship"
}

open class _NetOpsQueue: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "NetOpsQueue"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _NetOpsQueue.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var relationship: NSOrderedSet

    open func relationshipSet() -> NSMutableOrderedSet {
        return self.relationship.mutableCopy() as! NSMutableOrderedSet
    }

}

extension _NetOpsQueue {

    open func addRelationship(_ objects: NSOrderedSet) {
        let mutable = self.relationship.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.relationship = mutable.copy() as! NSOrderedSet
    }

    open func removeRelationship(_ objects: NSOrderedSet) {
        let mutable = self.relationship.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.relationship = mutable.copy() as! NSOrderedSet
    }

    open func addRelationshipObject(_ value: NetQueueOp) {
        let mutable = self.relationship.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.relationship = mutable.copy() as! NSOrderedSet
    }

    open func removeRelationshipObject(_ value: NetQueueOp) {
        let mutable = self.relationship.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.relationship = mutable.copy() as! NSOrderedSet
    }

}

