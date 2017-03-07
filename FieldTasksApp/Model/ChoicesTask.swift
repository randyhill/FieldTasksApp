import Foundation

@objc(ChoicesTask)
open class ChoicesTask: _ChoicesTask {
    var titles = [String]()
    override var editorId : String { get { return "ChoicesTaskEditor"} }
    override var viewerId : String { get { return "ChoicesTaskViewer"} }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let isRadio = dataDict["selections"] as? String {
            self.isRadio = (isRadio == "single") as NSNumber
        }
        if let titles = dataDict["choices"] as? [String] {
            self.titles = titles
        }
    }

    override func initResults(results : [String: AnyObject]) {
        //self.result = ChoicesResult(task: self, results: results)
        self.result = ChoicesResult()
        self.result?.task = self
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["selections"] = (isRadio!.boolValue ? "single" : "multiple") as AnyObject
        dict["choices"] = titles as AnyObject?
        return dict
    }

    override func taskDescriptionString() -> String {
        var descriptionString = isRadio!.boolValue ? "Select one of: " : "Select any of: "
        var selectionString : String?
        for selection in titles {
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
