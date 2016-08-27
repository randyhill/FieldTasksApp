//
//  TaskDescription.swift
//  FieldTasksApp
//
//  Created by CRH on 8/24/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation

class TaskDescription {

    init(dataDict : [String : AnyObject]) {

    }

    func toDict() -> [String : AnyObject]{
        return [String : AnyObject]()
    }
}

class TextTaskDescription : TaskDescription {

}

class NumberTaskDescription  : TaskDescription {
    var isDecimal = false
    var isUnlimited = true  // defaults to no range limits
    var min = 0             // We don't know if min/max types should be float or int yet
    var max = 0

    override init(dataDict : [String : AnyObject]) {
        super.init(dataDict: dataDict)

        if let isDecimal = dataDict["isDecimal"] as? Bool {
            self.isDecimal = isDecimal
        }
        if let limitBool = dataDict["range"] as? String {
            self.isUnlimited = (limitBool == "unlimited")
        }
        if let minVal = dataDict["min"] as? Int {
            self.min = minVal
        }
        if let maxVal = dataDict["max"] as? Int {
            self.max = maxVal
        }
    }
    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["isDecimal"] = isDecimal
        dict["range"] = isUnlimited ? "unlimited" : "limited"
        dict["min"] = min
        dict["max"] = max
        return dict
    }
}

class ChoicesTaskDescription  : TaskDescription {
    var isRadio = true
    var titles = [String]()

    override init(dataDict : [String : AnyObject]) {
        super.init(dataDict: dataDict)

        if let isRadio = dataDict["selections"] as? String {
            self.isRadio = (isRadio == "single")
        }
        if let titles = dataDict["choices"] as? [String] {
            self.titles = titles
        }
    }
    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["selections"] = isRadio ? "single" : "multiple"
        dict["choices"] = titles
        return dict
    }
}

class PhotoTaskDescription  : TaskDescription {

}

class WorkerTaskDescription  : TaskDescription {

}

class CustomerTaskDescription  : TaskDescription {
}