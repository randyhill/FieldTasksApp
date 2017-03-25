import Foundation
import CoreData

@objc(ChoicesResult)
open class ChoicesResult: _ChoicesResult {

    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)
        if let resultValues = results["values"] as? [String] {
            for value in resultValues {
                values! += [value]
            }
        }
    }


    func save(newValues: [String]) {
        values!.removeAll()
        values = newValues
        completed_private = (newValues.count > 0) as NSNumber
    }

    // MARK: Description  Methods -------------------------------------------------------------------------------
    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()

        if values!.count > 0 {
            dict["values"] = values as AnyObject?
        }
         return dict
    }

    override func resultString() -> String {
        var text = "Done: "
        var checked = 0

        for value in values! {
            // separate with checkmarks.
            if checked > 0 {
                text += ", "
            }
            text += value
            checked += 1
        }

        if checked == 0 {
            text += "No choices selected"
        }

        return text
    }
}
