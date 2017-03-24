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
    private var mainContext : NSManagedObjectContext?
    private var curContext : NSManagedObjectContext?

    func initModelContext(model : NSManagedObjectModel, context: NSManagedObjectContext) {
        self.model = model
        self.mainContext = context
        self.curContext = context
    }

    func setBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = self.mainContext?.persistentStoreCoordinator
        self.curContext = backgroundContext
        return backgroundContext
    }

    func restoreMainContext() {
        self.curContext = self.mainContext
    }

    func save() {
        // Core data functions need to be on same thread as context.
        //DispatchQueue.main.async {
            do {
                try self.curContext?.save()
            }   catch let error as NSError {
                FTErrorMessage(error: "Could not save data context: \(error), \(error.userInfo)")
            }
        //}
    }

    // MARK: Object Fetch/Remove Methods -------------------------------------------------------------------------------
    func fetchById(entityName: String, objectId: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try curContext!.fetch(fetchRequest)
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
            let objects = try curContext!.fetch(fetchRequest)
            FTAssert(isTrue: objects.count <= 1, error: "Multiple unsubmitted forms for template: \(templateId)")
            return objects.last as? Form
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch Form with id: \(templateId) - \(error), \(error.userInfo)")
        }
        return nil
    }

    // This will delete any objects of this entity type with given id, so if we accidently create duplicates it will clear them
    func deleteObject(object: AnyObject) {
        self.curContext?.delete(object as! NSManagedObject)
    }

    // This will delete any objects of this entity type with given id, so if we accidently create duplicates it will clear them
    func removeObjectById(entityName: String, objectId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%@", objectId)
        do {
            let objects = try curContext!.fetch(fetchRequest)
            FTAssert(isTrue: (objects.count != 0), error: "Could not find \(entityName) with id: \(objectId) to delete")
            for object in objects {
                self.curContext?.delete(object as! NSManagedObject)
            }
        } catch let error as NSError {
            FTErrorMessage(error: "Could not delete \(entityName) with id: \(objectId) - \(error), \(error.userInfo)")
        }
    }

    func fetchForms() -> [Form]? {
        if let entity = Form.entity(managedObjectContext: curContext!) {
            // Add predicate so we don't return subclasses of the class
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Form.entityName())
            fetchRequest.predicate = NSPredicate(format: "entity=%@", entity)
            do {
                let objects = try curContext!.fetch(fetchRequest)
                return objects as? [Form]
            } catch let error as NSError {
                FTErrorMessage(error: "Could not fetch list for: \(Form.entityName()) \(error), \(error.userInfo)")
            }
        }
        return nil
    }

    func fetchTemplates() -> [Template]? {
        if let entity = Template.entity(managedObjectContext: curContext!) {
            // Add predicate so we don't return subclasses of the class
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Template.entityName())
            fetchRequest.predicate = NSPredicate(format: "entity=%@", entity)
            do {
                let objects = try curContext!.fetch(fetchRequest)
                return objects as? [Template]
            } catch let error as NSError {
                FTErrorMessage(error: "Could not fetch list for: \(Template.entityName()) \(error), \(error.userInfo)")
            }
        }
        return nil
    }


    func fetchObjectsWithIds(entityName: String, ids: [String]) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            let objects = try curContext!.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch list for: \(entityName) \(error), \(error.userInfo)")
        }
        return nil
    }

    // MARK: Type specific Creation Methods -------------------------------------------------------------------------------
    func createLocation() -> FTLocation {
        let entity = NSEntityDescription.entity(forEntityName: FTLocation.entityName(), in: curContext!)
        return FTLocation(entity: entity!, insertInto: curContext)
    }

    func createTemplate() -> Template {
        let entity = NSEntityDescription.entity(forEntityName: "Template", in: curContext!)
        let template = Template(entity: entity!, insertInto: curContext)
        template.descriptionString = ""
        template.id = ""
        template.name = ""
        return template
    }

    func createForm() -> Form {
        let entity = NSEntityDescription.entity(forEntityName: "Form", in: curContext!)
        let form = Form(entity: entity!, insertInto: curContext)
        form.createDate = Date()
        form.locationId = ""
        form.templateId = ""
        return form
    }

    func createTaskResult(entityName: String, task: Task) -> TaskResult {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: curContext!)
        var taskResult : TaskResult?
        switch entityName {
        case "TextResult":
            taskResult = TextResult(entity: entity!, insertInto: curContext)
        case "NumberResult":
            taskResult = NumberResult(entity: entity!, insertInto: curContext)
        case "ChoicesResult":
            taskResult = ChoicesResult(entity: entity!, insertInto: curContext)
            if let result = taskResult as? ChoicesResult {
                result.values = [Bool]()
            }
        case "PhotosResult":
            taskResult = PhotosResult(entity: entity!, insertInto: curContext)
        default:
            FTErrorMessage(error: "Unknown entity name, could not create TaskResult")
            break
        }
        taskResult?.task = task
        return taskResult!
    }

    func createTask(entityName: String) -> Task {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: curContext!)
        var task : Task?
        switch entityName {
        case "TextTask":
            task = TextTask(entity: entity!, insertInto: curContext)
            if let task = task as? TextTask {
                task.isUnlimited = true
                task.max = 0
                task.type = TaskType.Text.rawValue
            }
        case "NumberTask":
            task = NumberTask(entity: entity!, insertInto: curContext)
            if let task = task as? NumberTask {
                task.isDecimal = false
                task.isUnlimited = true
                task.min = 0
                task.max = 0
                task.type = TaskType.Number.rawValue
            }
        case "ChoicesTask":
            task = ChoicesTask(entity: entity!, insertInto: curContext)
            if let task = task as? ChoicesTask {
                task.isRadio =  false
                task.type = TaskType.Choices.rawValue
                task.titles = [String]()
            }
        case "PhotosTask":
            task = PhotosTask(entity: entity!, insertInto: curContext)
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
    func fetchLocations() -> [FTLocation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FTLocation.entityName())
        do {
            let locations = try curContext!.fetch(fetchRequest)
            return locations as? [FTLocation]
        } catch let error as NSError {
            FTErrorMessage(error: "Could not fetch locations: \(error), \(error.userInfo)")
        }
        return nil
    }

}
