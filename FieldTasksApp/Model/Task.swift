import Foundation



@objc(Task)
open class Task: _Task {
    var editorId : String { get { return ""} }
    var viewerId : String { get { return ""} }

    func fromDict(taskDict : [String : AnyObject]) {
        self.name = taskDict["name"] as? String ?? ""
        self.id = taskDict["_id"] as? String ?? ""
        self.required = taskDict["required"] as? NSNumber ?? 0
        self.descriptionString = taskDict["description"] as? String ?? ""

        var dataDict = taskDict["data"] as? [String : AnyObject]
        if (dataDict == nil) {
            dataDict = [String : AnyObject]()
        }
        initTaskDescription(dataDict: dataDict!)

        var results = taskDict["results"] as? [String : AnyObject]
        if (results == nil) {
            results = [String : AnyObject]()
        }
        initResults(results: results!)
    }

    func initTaskDescription(dataDict : [String: AnyObject]) {
        FTErrorMessage(error: "This function must be overridden")
    }

    func resultTypeString() -> String {
        FTErrorMessage(error: "This function must be overridden")
        return ""
    }

    func initResults(results : [String: AnyObject]) {
        self.result = CoreDataMgr.shared.createTaskResult(entityName: self.resultTypeString(), task: self)
        self.result?.fromDict(results: results)
    }


    func toDict() -> [String : AnyObject]{
        var taskDict = [String : AnyObject]()

        // Dont' write id, as this is a different object to database
        taskDict["name"] = name as AnyObject?
        taskDict["type"] = type as AnyObject?
        taskDict["required"] = required as AnyObject?
        taskDict["description"] = descriptionString as AnyObject?
        taskDict["data"] = taskDescriptionDict() as AnyObject?
        taskDict["results"] = result?.toDict() as AnyObject?
        taskDict["name"] = name as AnyObject?
        return taskDict
    }

    func taskDescriptionDict() -> [String : AnyObject] {
        return [String : AnyObject]()
    }

    func taskDescriptionString() -> String {
        return ""
    }

    func isComplete() -> Bool {
        if required == false {
            return true
        }
        return result!.completed
    }
}
