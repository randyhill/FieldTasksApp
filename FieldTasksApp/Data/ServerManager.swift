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
let cAllTemplatesURL = cBaseURL + "/alltemplates"
let cFormsURL = cBaseURL + "/forms"
let cAllFormsURL = cBaseURL + "/allforms"
let cLocationsURL = cBaseURL + "/locations"
let cLocationTemplatesURL = cBaseURL + "/locations/templates"
let cUploadPhotoURL = cBaseURL + "/upload"
let cDownloadPhotoURL = cBaseURL + "/download/"

class ServerMgr {
    static let shared = ServerMgr()
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

    init() {

    }

    func loadTemplates(location: Location?, completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if var url = URL(string: cAllTemplatesURL) {
            if let location = location {
                url.appendPathComponent("/\(location.id)")
            }
            loadList(url: url, completion: completion)
        }
    }

    // Filter by location if set
    func loadForms(location: Location?, completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if var url = URL(string: cAllFormsURL) {
            if let location = location {
                url.appendPathComponent("/\(location.id)")
            }
            loadList(url: url, completion: completion)
        }
    }

    func loadLocations(completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if let url = URL(string: cLocationsURL) {
            loadList(url: url, completion: completion)
        }
    }

    private func loadList(url: URL, completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
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
            completion(response, response.result.isSuccess ? nil : "Failed to save form")
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

    func downloadFile(imageFileName : String, completion : @escaping (_ data : Data?, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.showProgress(0.01, status: "Downloading photo")

        // SVProgressHUD is run from operations queue, so queue upload so it doesn't start until after alert is visible.
        OperationQueue.main.addOperation({
           let path = cDownloadPhotoURL + imageFileName
            _ = Just.get(path, params: [:], asyncProgressHandler: {(p) in
                SVProgressHUD.showProgress(p.percent, status: "Downloading photo")
            }) { (result) in
                SVProgressHUD.dismiss()
                if let code = result.statusCode, code == 200   {
                    if let data = result.content {
                        return completion(data, nil)
                    } else {
                        return completion(nil, "Server did not have that image")
                    }
                } else {
                    return completion(nil, result.error != nil ?  result.error!.localizedDescription : "Server did not have that image")
                 }
            }
        })
    }

    func downloadFiles(photoFileList: PhotoFileList, imageUpdate : @escaping (_ updatedIndex: Int)->(), completion : @escaping (_ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // SVProgressHUD is run from operations queue, so queue upload so it doesn't start until after alert is visible.
        let mapArray = photoFileList.mapOfUnloaded()
        for map in mapArray {
            OperationQueue.main.addOperation({
               let path = cDownloadPhotoURL + map.fileName!
                _ = Just.get(path, params: [:]) { (result) in
                    if let code = result.statusCode, code == 200   {
                        // Copy image back to original photo result array
                        if let data = result.content {
                            if let image = UIImage(data: data) {
                                map.image = image
                            }
                            return imageUpdate(map.resultIndex)
                        } else {
                            FTErrorMessage(error: "Server did not have image: \(map.fileName!)")
                        }
                    } else {
                        FTErrorMessage(error: result.error != nil ?  result.error!.localizedDescription : "Server did not have that image")
                    }
                }
            })
        }
        OperationQueue.main.addOperation({
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return completion(nil)
        })
   }

    func uploadImages(photoFileList: PhotoFileList, completion : @escaping (_ photoFileList: PhotoFileList?, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.showProgress(0.01, status: "Uploading photos")

        // SVProgressHUD is run from operations queue, so queue upload so it doesn't start until after alert is visible.
        OperationQueue.main.addOperation({ 
            var files = [String:HTTPFile]()
            var fileIndex = 0
            for map in photoFileList.mapOfAllImages() {
                // Images saved to server are saved without proper orientation flag
                // This flag is not being saved to the exif data in the uploaded jpeg image, so make sure image is uploaded in 
                // vertical orientation as that's what it will display in when read back.
                if let data = UIImagePNGRepresentation(map.image!.fixOrientation()) {
                    files["\(fileIndex)"] = HTTPFile.data("\(fileIndex)", data, nil)
                    fileIndex += 1
                }
            }

            if let jsonDict = Just.post(cUploadPhotoURL, files: files, asyncProgressHandler: {(p) in
                SVProgressHUD.showProgress(p.percent, status: "Uploading photos")
            }).json {
                DispatchQueue.main.async() {
                    SVProgressHUD.dismiss(completion: {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if let fileArray = jsonDict as? [Any] {
                            photoFileList.addNamesFromJson(fileArray: fileArray)
                            completion(photoFileList, nil)
                        } else {
                            completion(nil, "Couldn't parse JSON")
                        }
                    })
                }
            }
        })
     }
}
