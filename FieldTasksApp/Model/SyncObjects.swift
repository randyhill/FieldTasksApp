//
//  SyncObjects.swift
//  FieldTasksApp
//
//  Created by CRH on 3/8/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

class SyncLocations {
    internal class func entityName() -> String {
        return FTLocation.entityName()
    }

    internal class  func createObject(objectDict: [String : AnyObject]) {
        let location = CoreDataMgr.shared.createLocation()
        location.fromDict(locationDict: objectDict)
    }

    internal class func updateObject(object : AnyObject, objectDict: [String : AnyObject]) {
        if let location = object as? FTLocation {
            location.fromDict(locationDict: objectDict)
        }
    }

    class func syncList(newList : [AnyObject]) -> String? {
        for dictionary in newList {
            if let objectDict = dictionary as? [String : AnyObject] {
                if let objectId = objectDict["_id"] as? String, let auditTrail = objectDict["auditTrail"] as? [String:Any] {
                      let object = CoreDataMgr.shared.fetchById(entityName: self.entityName(), objectId: objectId)
                    if let _ = auditTrail["deleted"] {
                        // Deleting ignores previously deleted objects, such as deleted before we first logged in.
                        if let _ = object {
                            CoreDataMgr.shared.removeObjectById(entityName: self.entityName(), objectId: objectId)
                        }
                    } else {
                        // Create new/update existing object
                        if let object = object {
                            self.updateObject(object: object, objectDict: objectDict)
                        } else {
                            self.createObject(objectDict: objectDict)
                        }
                    }
                } else {
                    return "Server sent incomplete \(entityName())"
                }
            }
        }
        CoreDataMgr.shared.save()
        return nil
    }
}

class SyncTemplates : SyncLocations {
    override class func entityName() -> String {
        return Template.entityName()
    }

    override class  func createObject(objectDict: [String : AnyObject]) {
        let template = CoreDataMgr.shared.createTemplate()
        template.fromDict(templateDict: objectDict)
    }

    override internal class func updateObject(object : AnyObject, objectDict: [String : AnyObject]) {
        if let template = object as? Template {
            template.fromDict(templateDict: objectDict)
        }
    }
}


class SyncForms : SyncLocations {
    override class func entityName() -> String {
        return Form.entityName()
    }

    override class  func createObject(objectDict: [String : AnyObject]) {
        let template = CoreDataMgr.shared.createForm()
        template.fromDict(formDict: objectDict)
    }

    override internal class func updateObject(object : AnyObject, objectDict: [String : AnyObject]) {
        if let form = object as? Form {
            form.fromDict(formDict: objectDict)
        }
    }
}

