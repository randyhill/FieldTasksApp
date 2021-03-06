//
//  PhotoFileList.swift
//  FieldTasksApp
//
//  Created by CRH on 1/27/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

// MARK: PhotoFileListMap  -------------------------------------------------------------------------------
// Map individual image to it's photoresult record and array index
class PhotoFileListMap {
    var imageIndex = 0
    var resultIndex = 0
    var result : PhotosResult?
    var image : UIImage? {
        get {
            if imageIndex < result!.count() {
                return result?.at(index: imageIndex)
            }
            return nil
        }
//        set (newImage) {
//            FTAssert(isTrue: newImage != nil, error: "Attempted to set nil image to photo result")
//            if imageIndex < result!.count() {
//                result!.set(photo: newImage!,  forIndex: imageIndex)
//            } else {
//                result!.add(photo: newImage!)
//            }
//        }
    }
    var fileName : String? {
        get {
            if imageIndex < result!.fileNames!.count {
                return result?.fileNames?[imageIndex]
            }
            return nil
        }
//        set (newFileName) {
//            FTAssert(isTrue: newFileName != nil, error: "Attempted to set nil file name to photo result")
//            if imageIndex < result!.fileNames!.count {
//                result!.set(fileName: newFileName!, forIndex: imageIndex)
//            } else {
//                result!.add(fileName: newFileName! )
//           }
//        }
    }

//    func set(fileName : String) {
//        result!.set(fileName: fileName, forIndex: imageIndex)
//    }

    init(imageIndex: Int, resultIndex : Int, result : PhotosResult) {
        self.result = result
        self.imageIndex = imageIndex
        self.resultIndex = resultIndex
    }
}

// MARK: PhotoFileList Methods -------------------------------------------------------------------------------
// Class used to pass multiple photos to server, and match results coming back to their tasks

// We want one big list of images from the form so they can all be uploaded at once and success confirmed before sending form data
// Some form tasks will have no image, some will have one, and some will have many, so we create a mapping array that maps each individual
// image back to it's task result. When the upload is completed it returns a JSON of the file names generated for the images, each mapped
// to the index of their PhotoMap entry.
class PhotoFileList {
    private var photoResults = [PhotosResult]()
    private var mapArray = [PhotoFileListMap]()

    var count : Int {
        get {
            return photoResults.count
        }
    }

    init(tasks: [Task]) {
        self.buildWithPhotos(tasks: tasks)
//        if buildWithImages {
//            self.buildWithPhotos(tasks: tasks)
//        } else {
//            self.buildWithFileNames(tasks: tasks)
//        }
    }

    // Create a list of all the form tasks that have images
    func buildWithPhotos(tasks : [Task]) {
        for resultIndex in 0 ..< tasks.count {
            let task = tasks[resultIndex]
            if let photoResult = task.result as? PhotosResult {
                if photoResult.count() > 0 {
                    for imageIndex in 0 ..< photoResult.count() {
                        let map = PhotoFileListMap(imageIndex: imageIndex, resultIndex: resultIndex, result: photoResult)
                        mapArray += [map]
                    }
                    photoResults += [photoResult]
                }
            }
        }
    }

    // Create a list of all the form tasks that have file names set
//    func buildWithFileNames(tasks : [Task]) {
//        for resultIndex in 0 ..< tasks.count {
//            let task = tasks[resultIndex]
//            if let photoResult = task.result as? PhotosResult {
//                if photoResult.fileNames!.count > 0 {
//                    for imageIndex in 0 ..< photoResult.fileNames!.count {
//                        let map = PhotoFileListMap(imageIndex: imageIndex, resultIndex: resultIndex, result: photoResult)
//                        mapArray += [map]
//                    }
//                    photoResults += [photoResult]
//                }
//            }
//        }
//    }

    func mapOfAllImages() -> [PhotoFileListMap] {
        return mapArray
    }

    func mapOfUnloaded() -> [PhotoFileListMap] {
        return mapArray.filter { (map) -> Bool in
            return (map.image == nil)
        }
    }

    // Sets file names for photo tasks results in Form.
    // JSON contains array index in mapArray for each fileName, add each to correct result in mapArray with
 //   func addNamesFromJson(fileArray : [Any]) {
//        // Now add submitted
//        for element in fileArray {
//            if let elementDict = element as? [String: String] {
//                if let fileIndex = elementDict["fileIndex"], let fileName = elementDict["fileName"] {
//                    if let arrayIndex = Int(fileIndex) {
//                        let map = mapArray[arrayIndex]
//                        map.result!.add(fileName: fileName)
//                    }
//                }
//            }
//        }
//    }
}
