//
//  CoreDataMgr.swift
//  FieldTasksApp
//
//  Created by CRH on 3/7/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataMgr {
    static let shared = CoreDataMgr()
    private var model : NSManagedObjectModel?
    private var context : NSManagedObjectContext?

    func setModelContext(model : NSManagedObjectModel, context: NSManagedObjectContext) {
        self.model = model
        self.context = context
    }

    func save() {
        do {
            try context?.save()
        }   catch let error as NSError {
            FTErrorMessage(error: "Could not save data context: \(error), \(error.userInfo)")
        }
    }

    func fetchById(entityName: String, objectId: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try context!.fetch(fetchRequest)
            if objects.count > 0 {
                FTAssert(isTrue: objects.count <= 1, error: "Multiple objects with id: \(objectId)")
                return objects[0] as AnyObject?
            }
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch \(entityName) with id: \(objectId) - \(error), \(error.userInfo)")
        }
        return nil
    }

    // This will delete any objects of this entity type with given id, so if we accidently create duplicates it will clear them
    func removeObjectById(entityName: String, objectId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try context!.fetch(fetchRequest)
            FTAssert(isTrue: (objects.count != 0), error: "Could not find \(entityName) with id: \(objectId) to delete")
            for object in objects {
                self.context?.delete(object as! NSManagedObject)
            }
        } catch let error as NSError {
            FTErrorMessage(error: "Could not delete \(entityName) with id: \(objectId) - \(error), \(error.userInfo)")
        }
    }

    // MARK: Creation Methods -------------------------------------------------------------------------------
    func createLocation() -> FTLocation {
        let entity = NSEntityDescription.entity(forEntityName: FTLocation.entityName(), in: context!)
        return FTLocation(entity: entity!, insertInto: context)
    }

    func createTemplate() -> Template {
        let entity = NSEntityDescription.entity(forEntityName: "Template", in: context!)
        return Template(entity: entity!, insertInto: context)
    }

    func createTaskResult(entityName: String, task: Task) -> TaskResult {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context!)
        var taskResult : TaskResult?
        switch entityName {
        case "TextResult":
            taskResult = TextResult(entity: entity!, insertInto: context)
        case "NumberResult":
            taskResult = NumberResult(entity: entity!, insertInto: context)
        case "ChoicesResult":
            taskResult = ChoicesResult(entity: entity!, insertInto: context)
        case "PhotosResult":
            taskResult = PhotosResult(entity: entity!, insertInto: context)
        default:
            FTErrorMessage(error: "Unknown entity name, could not create TaskResult")
            break
        }
        taskResult?.task = task
        return taskResult!
    }

    func createTask(entityName: String) -> Task {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context!)
        var task : Task?
        switch entityName {
        case "TextTask":
            task = TextTask(entity: entity!, insertInto: context)
        case "NumberTask":
            task = NumberTask(entity: entity!, insertInto: context)
        case "ChoicesTask":
            task = ChoicesTask(entity: entity!, insertInto: context)
        case "PhotosTask":
            task = PhotosTask(entity: entity!, insertInto: context)
        default:
            FTErrorMessage(error: "Unknown entity name, could not create Task")
            break
        }
        return task!
    }

    // MARK: Fetch Methods -------------------------------------------------------------------------------
    func fetchLocations() -> [FTLocation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FTLocation.entityName())
        do {
            let locations = try context!.fetch(fetchRequest)
            return locations as? [FTLocation]
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch locations: \(error), \(error.userInfo)")
        }
        return nil
    }

}
