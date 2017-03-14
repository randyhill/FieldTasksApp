import Foundation

@objc(Template)
open class Template: _Template {
    var tasks : [Task] {
        get {
            let setCopy = self.taskSet.mutableCopy() as! NSMutableOrderedSet
            return setCopy.array as! [Task]
        }
        set(newTasks) {
            let set = NSOrderedSet(array: newTasks)
            self.taskSet = set
            //self.addTaskSet(set)
        }
    }

    func fromDict(templateDict : [String : Any]) {
        self.name = templateDict["name"] as? String ?? ""
        self.descriptionString = templateDict["description"] as? String ?? ""
        self.id = templateDict["_id"] as? String ?? ""

        if let tasksArray = templateDict["tasks"] as? [AnyObject] {
            var newTasks = [Task]()
            for taskObject in tasksArray {
                if let taskDict = taskObject as? [String : AnyObject] {
                    if let newTask = TaskFromDictionary(taskDict: taskDict) {
                        newTasks += [newTask]
                    }
                }
            }
            self.tasks = newTasks
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
