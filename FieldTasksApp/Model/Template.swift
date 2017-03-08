import Foundation

@objc(Template)
open class Template: _Template {
    var tasks = [Task]()

    // init from existing
    func initFromTemplate(template: Template) {
        self.id = template.id
        self.name = template.name
        self.descriptionString = template.description
        self.tasks = template.tasks
    }

    func fromDict(templateDict : [String : Any]) {
        if let name = templateDict["name"] as? String {
            self.name = name
        }
        if let description = templateDict["description"] as? String {
            self.descriptionString = description
        }
        if let id = templateDict["_id"] as? String {
            self.id = id
        }
        if let tasksArray = templateDict["tasks"] as? [AnyObject] {
            for taskObject in tasksArray {
                if let taskDict = taskObject as? [String : AnyObject] {
                    if let newTask = TaskFromDictionary(taskDict: taskDict) {
                        self.tasks += [newTask]
                    }
                }
            }
        }
    }

    func toDict() -> [String : AnyObject]{
        var formDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        formDict["name"] = name as AnyObject?
        formDict["description"] = description as AnyObject?
        var taskDicts = [[String : AnyObject]]()
        for task in tasks {
            taskDicts += [task.toDict()]
        }
        formDict["tasks"] = taskDicts as AnyObject?
        return formDict
    }

    func tasksStillIncomplete() -> String? {
        var incompleteTasks : String?
        for task in tasks {
            if !task.isComplete() {
                if incompleteTasks == nil {
                    incompleteTasks = ""
                } else {
                    incompleteTasks! += ", "
                }
                incompleteTasks! += task.name!
            }
        }
        return incompleteTasks
    }
}
