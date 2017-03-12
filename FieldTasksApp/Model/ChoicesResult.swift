import Foundation
import CoreData

@objc(ChoicesResult)
open class ChoicesResult: _ChoicesResult {
    var values : [Bool] {
        get {
            return values_core as! [Bool]
        }
        set(newValues) {
            values_core = newValues as AnyObject
        }
    }

    // MARK: Initialization Methods -------------------------------------------------------------------------------
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)

        values_core = [Bool]() as AnyObject
    }
    
    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)
        if let resultValues = results["values"] as? [Bool] {
            for value in resultValues {
                values += [value]
            }
        }
    }


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

    // MARK: Description  Methods -------------------------------------------------------------------------------
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
