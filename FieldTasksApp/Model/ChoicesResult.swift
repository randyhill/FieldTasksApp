import Foundation

@objc(ChoicesResult)
open class ChoicesResult: _ChoicesResult {
    var values = [Bool]()
//    override init(task : Task, results: [String : AnyObject]) {
//        super.init(task: task, results: results)
//        if let resultValues = results["values"] as? [Bool] {
//            for value in resultValues {
//                values += [value]
//            }
//        }
//    }

    func save(newValues: [Bool]) {
        values.removeAll()
        completed_private = false
        for newValue in newValues {
            values += [newValue]
            if newValue {
               completed_private = true;
            }
        }
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()

        dict["values"] = values as AnyObject?
        return dict
    }

    override func resultString() -> String {
        var text = "Done: "
        if let choicesTask = task as? ChoicesTask {
            var checked = 0
            for (value, choice) in zip(values, choicesTask.titles) {
                if value {
                    // separate with checkmarks.
                    if checked > 0 {
                        text += ", "
                    }
                    text += choice
                    checked += 1
                }
            }
            if checked == 0 {
                text += "No choices selected"
            }
        }

        return text
    }
}
