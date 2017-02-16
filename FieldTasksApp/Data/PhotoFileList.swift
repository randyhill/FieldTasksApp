//
//  PhotoFileList.swift
//  FieldTasksApp
//
//  Created by CRH on 1/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class PhotoMap {
    var image : UIImage?
    var result : PhotoResult?

    init(image: UIImage, result : PhotoResult) {
        self.image = image
        self.result = result
    }
}

// Class used to pass multiple photos to server, and match results coming back to their tasks

// We want one big list of images from the form so they can all be uploaded at once and success confirmed before sending form data
// Some form tasks will have no image, some will have one, and some will have many, so we create a mapping array that maps each individual
// image back to it's task result. When the upload is completed it returns a JSON of the file names generated for the images, each mapped
// to the index of their PhotoMap entry.
class PhotoFileList {
    private var photoResults = [PhotoResult]()
    private var mapArray = [PhotoMap]()

    var count : Int {
        get {
            return photoResults.count
        }
    }

    init(tasks: [FormTask]) {
        self.addPhotoResults(tasks: tasks)
    }

    // Create a list of all the form tasks that have photos
    func addPhotoResults(tasks : [FormTask]) {
        for task in tasks {
            if let photoResult = task.result as? PhotoResult {
                if photoResult.photos.count > 0 {
                    for photo in photoResult.photos {
                        let map = PhotoMap(image: photo, result: photoResult)
                        mapArray += [map]
                    }
                    photoResults += [photoResult]
                }
            }
        }
    }

    func asImageArray() -> [PhotoMap] {
        return mapArray
    }

    // JSON contains array index in mapArray for each fileName, add each to correct result in mapArray with
    func addNamesFromJson(fileArray : [Any]) {
        // Now add submitted
        for element in fileArray {
            if let elementDict = element as? [String: String] {
                if let fileIndex = elementDict["fileIndex"], let fileName = elementDict["fileName"] {
                    if let arrayIndex = Int(fileIndex) {
                        let map = mapArray[arrayIndex]
                        map.result!.fileNames += [fileName]
                    }
                }
            }
        }
    }
}
