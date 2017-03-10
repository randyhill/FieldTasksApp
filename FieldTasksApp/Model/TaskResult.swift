import Foundation

@objc(TaskResult)
open class TaskResult: _TaskResult {
	// Custom logic goes here.
    var completed: Bool {
        get {
            return completed_private == true
        }
    }

    func fromDict(results: [String : AnyObject]) {
        completed_private = results["completed"] as? NSNumber ?? false
    }

    func toDict() -> [String : AnyObject]{
        var dict = [String : AnyObject]()
        dict["completed"] = (completed_private as NSNumber?) ?? false
        return dict
    }

    func save(newText : String) {

    }

    func resultString() -> String {
        return ""
    }
}
