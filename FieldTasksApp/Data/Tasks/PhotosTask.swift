//
//  PhotosTask.swift
//  FieldTasksApp
//
//  Created by CRH on 2/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

// MARK: PhotosTask Class -------------------------------------------------------------------------------
class PhotosTask : Task {
    var isSingle = false;
    override var editorId : String { get { return "PhotosTaskEditor"} }

    override init(taskDict : [String : AnyObject]) {
        super.init(taskDict: taskDict)
        self.type = TaskType.Photos
    }

    override func initTaskDescription(dataDict : [String: AnyObject]) {
        if let typeString = dataDict["selections"] as? String {
            if typeString == "single" {
                self.isSingle = true
            } else if typeString == "multiple" {
                self.isSingle = false
            }
        }
    }

    override func initResults(results : [String: AnyObject]) {
        self.result = PhotoResult(task: self, results: results)
    }

    override func taskDescriptionDict() -> [String : AnyObject]{
        var dict = super.taskDescriptionDict()
        dict["selections"] = (isSingle ? "single" : "multiple") as AnyObject
        return dict
    }

    override func taskDescriptionString() -> String {
        return isSingle ? "Single Photo" : "Multiple Photos"
    }
}

// MARK: PhotoResult Class -------------------------------------------------------------------------------
class PhotoResult : TaskResult {
    var photos = [UIImage]()
    var fileNames = [String]()

    override var completed: Bool {
        get {
            return (photos.count > 0)
        }
    }

    override init(task : Task, results: [String : AnyObject]) {
        super.init(task: task, results: results)
        if let fileNames = results["fileNames"] as? [String] {
            self.fileNames = fileNames
        }
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["fileNames"] = fileNames as AnyObject?
        return dict
    }
}
