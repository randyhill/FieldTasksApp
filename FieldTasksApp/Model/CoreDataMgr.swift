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

    func fetchUnfinishedFormByTemplateId(templateId: String) -> Form? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Form.entityName())
        fetchRequest.predicate = NSPredicate(format: "id='' AND templateId=%@", templateId)
        do {
            let objects = try context!.fetch(fetchRequest)
            FTAssert(isTrue: objects.count <= 1, error: "Multiple unsubmitted forms for template: \(templateId)")
            return objects.last as? Form
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch Form with id: \(templateId) - \(error), \(error.userInfo)")
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

    func fetchObjects(entityName: String) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let objects = try context!.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch list for: \(entityName) \(error), \(error.userInfo)")
        }
        return nil
    }

    func fetchObjectsWithIds(entityName: String, ids: [String]) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", ids)
        do {
            let objects = try context!.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch list for: \(entityName) \(error), \(error.userInfo)")
        }
        return nil
    }


    // MARK: Object specific Creation Methods -------------------------------------------------------------------------------
    func createLocation() -> FTLocation {
        let entity = NSEntityDescription.entity(forEntityName: FTLocation.entityName(), in: context!)
        return FTLocation(entity: entity!, insertInto: context)
    }

    func createTemplate() -> Template {
        let entity = NSEntityDescription.entity(forEntityName: "Template", in: context!)
        return Template(entity: entity!, insertInto: context)
    }

    func createForm() -> Form {
        let entity = NSEntityDescription.entity(forEntityName: "Form", in: context!)
        let form = Form(entity: entity!, insertInto: context)
        form.createDate = Date()
        form.locationId = ""
        form.templateId = ""
        return form
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
            if let task = task as? TextTask {
                task.isUnlimited = false
                task.max = 0
            }
        case "NumberTask":
            task = NumberTask(entity: entity!, insertInto: context)
            if let task = task as? NumberTask {
                task.isDecimal = false
                task.isUnlimited = false
                task.min = 0
                task.max = 0
            }
        case "ChoicesTask":
            task = ChoicesTask(entity: entity!, insertInto: context)
            if let task = task as? ChoicesTask {
                task.isRadio =  false
            }
        case "PhotosTask":
            task = PhotosTask(entity: entity!, insertInto: context)
            if let task = task as? PhotosTask {
                task.isSingle = false
            }
        default:
            FTErrorMessage(error: "Unknown entity name, could not create Task")
            break
        }
        task?.descriptionString = ""
        task?.id = ""
        task?.name = ""
        task?.required = false
        task?.type = ""
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
