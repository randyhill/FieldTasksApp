// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Login.swift instead.

import Foundation
import CoreData

public enum LoginAttributes: String {
    case account = "account"
    case email = "email"
    case expiration = "expiration"
    case token = "token"
}

open class _Login: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Login"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Login.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var account: String?

    @NSManaged open
    var email: String?

    @NSManaged open
    var expiration: NSNumber?

    @NSManaged open
    var token: String?

    // MARK: - Relationships

}

