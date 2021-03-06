import Foundation
import CoreData

@objc(ChoicesTask)
open class ChoicesTask: _ChoicesTask {
    override var editorId : String { get { return "ChoicesTaskEditor"} }
    override var viewerId : String { get { return "ChoicesTaskViewer"} }

    // MARK: Initialization Methods -------------------------------------------------------------------------------

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let isRadio = dataDict["selections"] as? String {
            self.isRadio = (isRadio == "single") as NSNumber
        }
        if let hasOther = dataDict["hasOther"] as? NSNumber {
            self.hasOther = hasOther
        }
        if let titles = dataDict["choices"] as? [String] {
            self.titles = titles
        }
    }

    // MARK: Description Methods -------------------------------------------------------------------------------
    override func resultTypeString() -> String {
        return "ChoicesResult"
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["selections"] = (isRadio!.boolValue ? "single" : "multiple") as AnyObject
        dict["choices"] = titles as AnyObject?
        dict["hasOther"] = hasOther!.boolValue as AnyObject
        return dict
    }

    override func taskDescriptionString() -> String {
        var descriptionString = isRadio!.boolValue ? "Select one of: " : "Select any of: "
        var selectionString : String?
        for selection in titles! {
            if selectionString == nil {
                selectionString = selection
            } else {
                selectionString = ", " + selection
            }
            descriptionString += selectionString!
        }
        return descriptionString
    }
}
