//
//  SyncObjects.swift
//  FieldTasksApp
//
//  Created by CRH on 3/8/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation
import CoreData

let cTemplatesUpdateNotification = Notification.Name("TemplatesUpdated")
let cLocationsUpdateNotification = Notification.Name("LocationsUpdated")
let cFormsUpdateNotification = Notification.Name("FormsUpdated")

class SyncMgr {
    static let shared = SyncMgr()
    let cSyncValue = "ServerSync"
    var lastSync : Date?

    init() {
        self.lastSync = Globals.getSettingsValue(key: cSyncValue) as? Date ?? Globals.shared.stringToDate(dateString: "2017-01-01")
    }

    // Get updated/new/deleted Templates/Forms/Locations and update coredata
    func sync(context: NSManagedObjectContext, completion: @escaping ( _ updated: (templates : Int, locations : Int, forms : Int, error: String?))->()) {
        ServerMgr.shared.syncAll(sinceDate: self.lastSync!) { (data, timeStamp, error) in
            FTAssert(exists: timeStamp, error: "No time stamp for sync")
            FTAssert(exists: data, error: "No result for sync")
            if let error = error {
                completion((0, 0, 0, error))
            } else if let syncDict = data {
                // Error Strategy : Errors in this section should only because of two reasons
                // 1) List object couldn't be parsed because it's incomplete, because App/Server API returning data in wrong format (API wrong version?)
                // 2) JSON object data is incomplete because of network error. Hard to imagine we reach this section if that happens,  as ServerMgr should error out first.
                // Anyways we aren't marking Sync as successful unless all data was processed successfully, so 1) will lead to user unable to use app, ie 
                // never having successful sync until app/server API is fixed. But a resync can fix 2) if it could ever happen.
                var error: String?
                var templates = 0
                var locations = 0
                var forms = 0
                if let templateList = syncDict["Templates"] as? [AnyObject]  {
                    let synced = SyncTemplates.syncList(context: context, newList: templateList)
                    templates = synced.updated
                    error = synced.error
                }
                if error == nil, let locationList = syncDict["Locations"] as? [AnyObject]  {
                    let synced = SyncLocations.syncList(context: context, newList: locationList)
                    locations = synced.updated
                    error = synced.error
                }
                if error == nil, let formsList = syncDict["Forms"] as? [AnyObject]  {
                    let synced = SyncForms.syncList(context: context, newList: formsList)
                    forms = synced.updated
                    error = synced.error
               }
                if  error == nil {
                    self.lastSync = timeStamp
                    Globals.saveSettingsValue(key: self.cSyncValue, value: timeStamp as AnyObject)
                }
                CoreDataMgr.shared.saveOnMainThread()
                completion((templates: templates, locations: locations, forms: forms, error: error))
            }
        }
    }
}

class SyncLocations {
    internal class func entityName() -> String {
        return FTLocation.entityName()
    }

    internal class  func createObject(context: NSManagedObjectContext, objectDict: [String : AnyObject]) {
        let location = CoreDataMgr.shared.createLocation(context: CoreDataMgr.shared.mainThreadContext!)
        location.fromDict(locationDict: objectDict)
    }

    internal class func updateObject(context: NSManagedObjectContext, object : AnyObject, objectDict: [String : AnyObject]) {
        if let location = object as? FTLocation {
            location.fromDict(locationDict: objectDict)
        }
    }

    class func syncList(context: NSManagedObjectContext, newList : [AnyObject]) -> (updated: Int, error: String?) {
        var updated = 0
        for dictionary in newList {
            if let objectDict = dictionary as? [String : AnyObject] {
                if let objectId = objectDict["_id"] as? String, let auditTrail = objectDict["auditTrail"] as? [String:Any] {
                      let object = CoreDataMgr.shared.fetchById(context: context, entityName: self.entityName(), objectId: objectId)
                    if let _ = auditTrail["deleted"] {
                        // Deleting ignores previously deleted objects, such as deleted before we first logged in.
                        if let _ = object {
                            CoreDataMgr.shared.removeObjectById(context: context, entityName: self.entityName(), objectId: objectId)
                            updated += 1
                        }
                    } else {
                        // Create new/update existing object
                        if let object = object {
                            self.updateObject(context: context, object: object, objectDict: objectDict)
                            updated += 1
                        } else {
                            self.createObject(context: context, objectDict: objectDict)
                            updated += 1
                        }
                    }
                } else {
                    return (updated: updated, error: "Server sent incomplete \(entityName())")
                }
            }
        }
      //  CoreDataMgr.shared.saveOnMainThread()
        return (updated: updated, error: nil)
    }
}

class SyncTemplates : SyncLocations {
    override class func entityName() -> String {
        return Template.entityName()
    }

    override class  func createObject(context: NSManagedObjectContext, objectDict: [String : AnyObject]) {
        let template = CoreDataMgr.shared.createTemplate(context: context)
        template.fromDict(context: context, templateDict: objectDict)
    }

    override internal class func updateObject(context: NSManagedObjectContext, object : AnyObject, objectDict: [String : AnyObject]) {
        if let template = object as? Template {
            template.fromDict(context: context, templateDict: objectDict)
        }
    }
}


class SyncForms : SyncLocations {
    override class func entityName() -> String {
        return Form.entityName()
    }

    override class  func createObject(context: NSManagedObjectContext, objectDict: [String : AnyObject]) {
        let template = CoreDataMgr.shared.createForm(context: context)
        template.fromDict(context: context, formDict: objectDict)
    }

    override internal class func updateObject(context: NSManagedObjectContext, object : AnyObject, objectDict: [String : AnyObject]) {
        if let form = object as? Form {
            form.fromDict(context: context, formDict: objectDict)
        }
    }
}

