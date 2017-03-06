import Foundation
import CoreData

@objc(TaskResult)
open class TaskResult: _TaskResult {
	// Custom logic goes here.
    var completed: Bool {
        get {
            return completed_private == true
        }
    }

    convenience init(task : Task) {
        self.init(managedObjectContext: Globals.shared.context!)!
        self.task = task
    }

    func toDict() -> [String : AnyObject]{
        var dict = [String : AnyObject]()
        dict["completed"] = completed as AnyObject?
        return dict
    }

    func save(newText : String) {

    }

    func resultString() -> String {
        return ""
    }
}
