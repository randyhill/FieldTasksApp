//
//  PhotoFileList.swift
//  FieldTasksApp
//
//  Created by CRH on 1/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

// Map individual image to it's photoresult record and array index
class PhotoMap {
    var imageIndex = 0
    var resultIndex = 0
    var result : PhotosResult?
    var image : UIImage? {
        get {
            if imageIndex < result!.photos.count {
                return result?.photos[imageIndex]
            }
            return nil
        }
        set (newImage) {
            FTAssert(isTrue: newImage != nil, error: "Attempted to set nil image to photo result")
            if imageIndex < result!.photos.count {
                result!.photos[imageIndex] = newImage!
            } else {
                result!.photos += [newImage!]
            }
        }
    }
    var fileName : String? {
        get {
            if imageIndex < result!.fileNames!.count {
                return result?.fileNames?[imageIndex]
            }
            return nil
        }
        set (newFileName) {
            FTAssert(isTrue: newFileName != nil, error: "Attempted to set nil file name to photo result")
            if imageIndex < result!.fileNames!.count {
                result!.fileNames![imageIndex] = newFileName!
            } else {
                result!.fileNames! += [newFileName!]
            }
        }
    }

    init(imageIndex: Int, resultIndex : Int, result : PhotosResult) {
        self.result = result
        self.imageIndex = imageIndex
        self.resultIndex = resultIndex
    }
}

// Class used to pass multiple photos to server, and match results coming back to their tasks

// We want one big list of images from the form so they can all be uploaded at once and success confirmed before sending form data
// Some form tasks will have no image, some will have one, and some will have many, so we create a mapping array that maps each individual
// image back to it's task result. When the upload is completed it returns a JSON of the file names generated for the images, each mapped
// to the index of their PhotoMap entry.
class PhotoFileList {
    private var photoResults = [PhotosResult]()
    private var mapArray = [PhotoMap]()

    var count : Int {
        get {
            return photoResults.count
        }
    }

    init(tasks: [Task], buildWithImages: Bool) {
        if buildWithImages {
            self.buildWithPhotos(tasks: tasks)
        } else {
            self.buildWithFileNames(tasks: tasks)
        }
    }

    // Create a list of all the form tasks that have images
    func buildWithPhotos(tasks : [Task]) {
        for resultIndex in 0 ..< tasks.count {
            let task = tasks[resultIndex]
            if let photoResult = task.result as? PhotosResult {
                if photoResult.photos.count > 0 {
                    for imageIndex in 0 ..< photoResult.photos.count {
                        let map = PhotoMap(imageIndex: imageIndex, resultIndex: resultIndex, result: photoResult)
                        mapArray += [map]
                    }
                    photoResults += [photoResult]
                }
            }
        }
    }

    // Create a list of all the form tasks that have file names set
    func buildWithFileNames(tasks : [Task]) {
        for resultIndex in 0 ..< tasks.count {
            let task = tasks[resultIndex]
            if let photoResult = task.result as? PhotosResult {
                if photoResult.fileNames!.count > 0 {
                    for imageIndex in 0 ..< photoResult.fileNames!.count {
                        let map = PhotoMap(imageIndex: imageIndex, resultIndex: resultIndex, result: photoResult)
                        mapArray += [map]
                    }
                    photoResults += [photoResult]
                }
            }
        }
    }

    func mapOfAllImages() -> [PhotoMap] {
        return mapArray
    }

    func mapOfUnloaded() -> [PhotoMap] {
        return mapArray.filter { (map) -> Bool in
            return (map.image == nil)
        }
    }

    // JSON contains array index in mapArray for each fileName, add each to correct result in mapArray with
    func addNamesFromJson(fileArray : [Any]) {
        // Now add submitted
        for element in fileArray {
            if let elementDict = element as? [String: String] {
                if let fileIndex = elementDict["fileIndex"], let fileName = elementDict["fileName"] {
                    if let arrayIndex = Int(fileIndex) {
                        let map = mapArray[arrayIndex]
                        map.result!.fileNames! += [fileName]
                    }
                }
            }
        }
    }
}
