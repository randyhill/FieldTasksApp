import Foundation

@objc(Template)
open class Template: _Template {
    var tasks = [Task]()

    // init from existing
    func initFromTemplate(template: Template) {
        self.id = template.id
        self.name = template.name
        self.descriptionString = template.descriptionString
        self.tasks = template.tasks
    }

    func fromDict(templateDict : [String : Any]) {
        self.name = templateDict["name"] as? String ?? ""
        self.descriptionString = templateDict["description"] as? String ?? ""
        self.id = templateDict["_id"] as? String ?? ""

        if let tasksArray = templateDict["tasks"] as? [AnyObject] {
            tasks.removeAll()
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
        formDict["description"] = descriptionString as AnyObject?
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