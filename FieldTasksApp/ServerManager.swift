//
//  ServerMgr
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Just
import SVProgressHUD

#if LOCALHOST
let cBaseURL = "http://localhost:8080"
#else
let cBaseURL = "http://www.fieldtasks.co"
#endif

let cTemplatesURL = cBaseURL + "/templates"
let cFormsURL = cBaseURL + "/forms"
let cUploadPhotoURL = cBaseURL + "/upload"


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

class ServerMgr {
    static let shared = ServerMgr()
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

    init() {

    }

    func loadTemplates(completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if let url = NSURL(string: cTemplatesURL) {
            loadList(url: url, completion: completion)
        }
    }

    func loadForms(completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if let url = NSURL(string: cFormsURL) {
            loadList(url: url, completion: completion)
        }
    }

    private func loadList(url: NSURL, completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask = defaultSession.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                completion(nil, error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let jsonData = data {
                        do {
                            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                            if let formList = jsonDict as? [AnyObject] {
                                completion(formList, nil)
                            }

                        } catch {
                            completion(nil, "Couldn't parse JSON: \(error)")
                        }

                    }

                }
            }
        })
        dataTask.resume()
    }

    func saveAsForm(form: Template, completion : @escaping (_ result: Any?, _ error: String?)->()) {
        saveTemplateForm(form: form, url: cFormsURL, successCode: 201, completion: completion)
    }

    private func saveTemplateForm(form: Template, url: String, successCode: Int, completion : @escaping (_ result: Any?, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let formDict = form.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        Alamofire.request(url + "/", method: .post, parameters: formDict, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            completion(nil, nil)
        })
    }

    func uploadImage(image: UIImage, progress : @escaping (Float)->(), completion : @escaping (_ fileName: String, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        if let data = UIImagePNGRepresentation(image) {
            if var fileId = Just.post(cUploadPhotoURL, files: ["image" : .data("image.jpg", data, nil)], asyncProgressHandler: {(p) in
                progress(p.percent)
            }).text {
                DispatchQueue.main.async() {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                // fileId string should be 12 characters, plus quotes
                if fileId.characters.count > 12 {
                    // Remove quotes
                    fileId.remove(at: fileId.index(before: fileId.endIndex))
                    fileId.remove(at: fileId.startIndex)
                    completion(fileId, nil)
                } else {
                    completion("",  "Upload failed")
                }
            }
        }
    }


    func uploadImages(photoFileList: PhotoFileList, progress : @escaping (Float)->(), completion : @escaping (_ photoFileList: PhotoFileList?, _ error: String?)->()) {

        DispatchQueue.main.async() {
            // Start spinner
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            SVProgressHUD.showProgress(0)

            var files = [String:HTTPFile]()
            var fileNumber = 0
            for image in photoFileList.asImageArray() {
                if let data = UIImagePNGRepresentation(image) {
                    files["\(fileNumber)"] = HTTPFile.data("\(fileNumber)", data, nil)
                    fileNumber += 1
                }
            }

            if let jsonDict = Just.post(cUploadPhotoURL, files: files, asyncProgressHandler: {(p) in
                progress(p.percent)
                SVProgressHUD.showProgress(p.percent)
            }).json {
                DispatchQueue.main.async() {
                    SVProgressHUD.dismiss(completion: { 
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let fileArray = jsonDict as? [Any] {
                            for element in fileArray {
                                if let elementDict = element as? [String: String] {
                                    if let fileIndex = elementDict["fileIndex"], let fileName = elementDict["fileName"] {
                                        photoFileList.addFileName(name: fileName, listIndex: fileIndex)
                                    }
                                }
                            }
                            completion(photoFileList, nil)
                        } else {
                            completion(nil, "Couldn't parse JSON")
                        }
                    })
                }
            }
        }
    }
}
