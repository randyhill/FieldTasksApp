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
    var mainThreadContext : NSManagedObjectContext?

    func initModelContext(model : NSManagedObjectModel, context: NSManagedObjectContext) {
        self.model = model
        self.mainThreadContext = context
     }

    func getNewContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = self.mainThreadContext?.persistentStoreCoordinator
        return backgroundContext
    }

    func saveInContext(context : NSManagedObjectContext) {
        do {
            try context.save()
        }   catch let error as NSError {
            FTErrorMessage(error: "Could not save data context: \(error), \(error.userInfo)")
        }
    }

    func saveOnMainThread() {
        DispatchQueue.main.async {
            do {
                try self.mainThreadContext?.save()
            }   catch let error as NSError {
                FTErrorMessage(error: "Could not save data context: \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: Object Fetch/Remove Methods -------------------------------------------------------------------------------
    func fetchById(context : NSManagedObjectContext, entityName: String, objectId: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.count > 0 {
                FTAssert(isTrue: objects.count <= 1, error: "Multiple objects with id: \(objectId)")
                return objects[0] as AnyObject?
            }
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch \(entityName) with id: \(objectId) - \(error), \(error.userInfo)")
        }
        return nil
    }

    func fetchUnfinishedFormByTemplateId(context : NSManagedObjectContext, templateId: String) -> Form? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Form.entityName())
        fetchRequest.predicate = NSPredicate(format: "id='' AND templateId=%@", templateId)
        do {
            let objects = try context.fetch(fetchRequest)
            FTAssert(isTrue: objects.count <= 1, error: "Multiple unsubmitted forms for template: \(templateId)")
            return objects.last as? Form
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch Form with id: \(templateId) - \(error), \(error.userInfo)")
        }
        return nil
    }

    // This will delete any objects of this entity type with given id, so if we accidently create duplicates it will clear them
    func deleteObject(context : NSManagedObjectContext, object: AnyObject) {
        context.delete(object as! NSManagedObject)
    }

    // This will delete any objects of this entity type with given id, so if we accidently create duplicates it will clear them
    func removeObjectById(context : NSManagedObjectContext, entityName: String, objectId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try context.fetch(fetchRequest)
            FTAssert(isTrue: (objects.count != 0), error: "Could not find \(entityName) with id: \(objectId) to delete")
            for object in objects {
                context.delete(object as! NSManagedObject)
            }
        } catch let error as NSError {
            FTErrorMessage(error: "Could not delete \(entityName) with id: \(objectId) - \(error), \(error.userInfo)")
        }
    }

    func fetchForms(context : NSManagedObjectContext) -> [Form]? {
        if let entity = Form.entity(managedObjectContext: context) {
            // Add predicate so we don't return subclasses of the class
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Form.entityName())
            fetchRequest.predicate = NSPredicate(format: "entity=%@", entity)
            do {
                let objects = try context.fetch(fetchRequest)
                return objects as? [Form]
            } catch let error as NSError {
                FTErrorMessage(error: "Could not fetch list for: \(Form.entityName()) \(error), \(error.userInfo)")
            }
        }
        return nil
    }

    func fetchTemplates(context : NSManagedObjectContext) -> [Template]? {
        if let entity = Template.entity(managedObjectContext: context) {
            // Add predicate so we don't return subclasses of the class
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Template.entityName())
            fetchRequest.predicate = NSPredicate(format: "entity=%@", entity)
            do {
                let objects = try context.fetch(fetchRequest)
                return objects as? [Template]
            } catch let error as NSError {
                FTErrorMessage(error: "Could not fetch list for: \(Template.entityName()) \(error), \(error.userInfo)")
            }
        }
        return nil
    }


    func fetchObjectsWithIds(context : NSManagedObjectContext, entityName: String, ids: [String]) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            let objects = try context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch list for: \(entityName) \(error), \(error.userInfo)")
        }
        return nil
    }

    // MARK: Type specific Creation Methods -------------------------------------------------------------------------------
    class func createNetOp(context : NSManagedObjectContext) -> NetOpData {
        let entity = NSEntityDescription.entity(forEntityName: NetOpData.entityName(), in: context)
        return NetOpData(entity: entity!, insertInto: context)
    }

    func createLocation(context : NSManagedObjectContext) -> FTLocation {
        let entity = NSEntityDescription.entity(forEntityName: FTLocation.entityName(), in: context)
        return FTLocation(entity: entity!, insertInto: context)
    }

    func createTemplate(context : NSManagedObjectContext) -> Template {
        let entity = NSEntityDescription.entity(forEntityName: "Template", in: context)
        let template = Template(entity: entity!, insertInto: context)
        template.descriptionString = ""
        template.id = ""
        template.name = ""
        return template
    }

    func createForm(context : NSManagedObjectContext) -> Form {
        let entity = NSEntityDescription.entity(forEntityName: "Form", in: context)
        let form = Form(entity: entity!, insertInto: context)
        form.createDate = Date()
        form.locationId = ""
        form.templateId = ""
        return form
    }

    func createTaskResult(context : NSManagedObjectContext, entityName: String, task: Task) -> TaskResult {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        var taskResult : TaskResult?
        switch entityName {
        case "TextResult":
            taskResult = TextResult(entity: entity!, insertInto: context)
        case "NumberResult":
            taskResult = NumberResult(entity: entity!, insertInto: context)
        case "ChoicesResult":
            taskResult = ChoicesResult(entity: entity!, insertInto: context)
            if let result = taskResult as? ChoicesResult {
                result.values = [String]()
            }
        case "PhotosResult":
            taskResult = PhotosResult(entity: entity!, insertInto: context)
        default:
            FTErrorMessage(error: "Unknown entity name, could not create TaskResult")
            break
        }
        taskResult?.task = task
        return taskResult!
    }

    func createTask(context : NSManagedObjectContext, entityName: String) -> Task {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        var task : Task?
        switch entityName {
        case "TextTask":
            task = TextTask(entity: entity!, insertInto: context)
            if let task = task as? TextTask {
                task.isUnlimited = true
                task.max = 0
                task.type = TaskType.Text.rawValue
            }
        case "NumberTask":
            task = NumberTask(entity: entity!, insertInto: context)
            if let task = task as? NumberTask {
                task.isDecimal = false
                task.isUnlimited = true
                task.min = 0
                task.max = 0
                task.type = TaskType.Number.rawValue
            }
        case "ChoicesTask":
            task = ChoicesTask(entity: entity!, insertInto: context)
            if let task = task as? ChoicesTask {
                task.isRadio =  false
                task.hasOther = false
                task.type = TaskType.Choices.rawValue
                task.titles = [String]()
            }
        case "PhotosTask":
            task = PhotosTask(entity: entity!, insertInto: context)
            if let task = task as? PhotosTask {
                task.isSingle = true
                task.type = TaskType.Photos.rawValue
            }
        default:
            FTErrorMessage(error: "Unknown entity name, could not create Task")
            break
        }
        task?.descriptionString = ""
        task?.id = ""
        task?.name = ""
        task?.required = false
        return task!
    }

    // MARK: Fetch Methods -------------------------------------------------------------------------------
    func fetchLocations(context : NSManagedObjectContext) -> [FTLocation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FTLocation.entityName())
        do {
            let locations = try context.fetch(fetchRequest)
            return locations as? [FTLocation]
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch locations: \(error), \(error.userInfo)")
        }
        return nil
    }

}
