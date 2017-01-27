//
//  PhotoFileList.swift
//  FieldTasksApp
//
//  Created by CRH on 1/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

// Class used to pass multiple photos to server, and match results coming back to their tasks
class PhotoFileList {
    var photoResults = [PhotoResult]()

    init(tasks: [FormTask]) {
        self.addPhotoResults(tasks: tasks)
    }

    // Create a list of all the form tasks that have photos
    func addPhotoResults(tasks : [FormTask]) {
        for task in tasks {
            if let photoResult = task.result as? PhotoResult {
                if photoResult.photo != nil {
                    photoResults += [photoResult]
                }
            }
        }
    }

    // File names are sent to/recieved from server with indexes 1,2,3..etc
    func addFileName(name: String, listIndex : String) {
        if let index = Int(listIndex) {
            if index >= 0 && index < photoResults.count {
                photoResults[index].fileName = name
            }
        }
    }

    func asImageArray() -> [UIImage] {
        var array = [UIImage]()
        for photoResult in photoResults {
            array += [photoResult.photo!]
        }
        return array
    }
}
