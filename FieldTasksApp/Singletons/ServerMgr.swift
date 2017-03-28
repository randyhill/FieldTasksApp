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

typealias loadListCallback = (_ result: [AnyObject]?, _ timeStamp: Date,  _ error: String?)->()

class ServerMgr {
    static let shared = ServerMgr()
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

    init() {

    }

    // MARK: Sync All -------------------------------------------------------------------------------
    // Get all synced objects at once, returns new/modified/deleted Templates/Forms/Locations in JSON dictionary
    func syncAll(sinceDate: Date, completion : @escaping (_ result: [String: Any]?, _ timeStamp: Date,  _ error: String?)->()) {
        guard let encodedDateString = Globals.shared.encodeDate(date: sinceDate) else {
            FTErrorMessage(error: "Date string could not be encoded")
            return
        }
        guard let url = URL(string: cBaseURL + "/sync/" + encodedDateString) else {
            FTErrorMessage(error: "URL couldn't be created, server sync could not be invoked")
            return
        }

        // Turn on network indicator and get sync data from server
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask = defaultSession.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                completion(nil, Date(), error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                // If we can't parse server timestamp just use now
               var timeStamp = Date()
                if let timeStampString = httpResponse.allHeaderFields["Date"] as? String, let serverDate =  Globals.shared.serverStringToDate(dateString: timeStampString) {
                    timeStamp =  serverDate
                }

                if httpResponse.statusCode == 200 {
                    if let jsonData = data {
                        do {
                            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                            if let jsonDict = jsonDict as? [String: Any] {
                                completion(jsonDict, timeStamp, nil)
                            }

                        } catch {
                            completion(nil, timeStamp, "Couldn't parse JSON: \(error)")
                        }
                    }
                } else {
                    completion(nil, timeStamp, "Failed with: \(httpResponse.statusCode) status code")
                }
            }
        })
        dataTask.resume()
    }

    // MARK: Object Lists Methods -------------------------------------------------------------------------------
    private func loadList(url: URL?, completion : @escaping loadListCallback) {
        guard let url = url else {
            FTErrorMessage(error: "URL couldn't be created, server loadList could not be invoked")
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask = defaultSession.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            // If we can't parse server timestamp just use now
            if let error = error {
                completion(nil, Date(), error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                var timeStamp = Date()
                if let timeStampString = httpResponse.allHeaderFields["Date"] as? String, let serverDate =  Globals.shared.serverStringToDate(dateString: timeStampString) {
                    timeStamp =  serverDate
                }

                if httpResponse.statusCode == 200 {
                    if let jsonData = data {
                        do {
                            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                            if let formList = jsonDict as? [AnyObject] {
                                completion(formList, timeStamp, nil)
                            }

                        } catch {
                            completion(nil, timeStamp, "Couldn't parse JSON: \(error)")
                        }
                    }
                } else {
                    completion(nil, timeStamp, "Failed with: \(httpResponse.statusCode) status code")
                }
            }
        })
        dataTask.resume()
    }

    private func newTemplateForm(form: Template, url: String, successCode: Int, completion : @escaping (_ result: [String: Any]?, _ error: String?)->()) {
        // Start spinner
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let formDict = form.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        let url = url + "/"
        Alamofire.request(url, method: .post, parameters: formDict, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
//            DispatchQueue.main.async() {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
            var resultDict : [String : Any]?
            if response.result.isSuccess, let jsonData = response.data {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                    resultDict = jsonDict as? [String: Any]
                } catch {
                    completion(nil, "Couldn't parse JSON: \(error)")
                }
            }
            completion(resultDict, response.result.isSuccess ? nil : "Failed to save form")
        })
    }

    private func saveTemplateForm(form: Template, url: String, successCode: Int, completion : @escaping (_ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let formDict = form.toDict()

        let url = url + "/" + form.id!
        Alamofire.request(url, method: .put, parameters: formDict, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            completion(response.result.isSuccess ? nil : "Failed to save form")
        })
    }

    // MARK: Templates Methods -------------------------------------------------------------------------------
    func loadTemplates(location: FTLocation?, completion : @escaping loadListCallback) {
        if var url = URL(string: cAllTemplatesURL) {
            if let location = location {
                url.appendPathComponent("/\(location.id)")
            }
            loadList(url: url, completion: completion)
        }
    }

    func syncTemplates(sinceDate: Date, completion : @escaping loadListCallback) {
        if let encodedDateString = Globals.shared.encodeDate(date: sinceDate) {
            let urlString = cTemplatesURL + "/sync/" + encodedDateString
            loadList(url: URL(string: urlString), completion: completion)
        } else {
            FTErrorMessage(error: "Bad string for date")
        }
    }

    func deleteTemplate(templateId: String, completion : @escaping (_ error : String?)->()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = cTemplatesURL + "/" + templateId
        Alamofire.request(url, method: .delete, parameters: ["id":templateId], encoding: JSONEncoding.default, headers: nil).responseString(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            completion(response.error?.localizedDescription)
        })
    }

    func newTemplate(template: Template, completion : @escaping (_ result: [String : Any]?, _ error: String?)->()) {
        newTemplateForm(form: template, url: cTemplatesURL, successCode: 201, completion: completion)
    }

    func saveTemplate(template: Template, completion : @escaping (_ error: String?)->()) {
        saveTemplateForm(form: template, url: cTemplatesURL, successCode: 201, completion: completion)
    }

    // MARK: Forms Methods -------------------------------------------------------------------------------

    // Filter by location if set
    func loadForms(location: FTLocation?, completion : @escaping loadListCallback) {
        if var url = URL(string: cAllFormsURL) {
            if let location = location {
                url.appendPathComponent("/\(location.id)")
            }
            loadList(url: url, completion: completion)
        }
    }

    func syncForms(sinceDate: Date, completion : @escaping loadListCallback) {
        if let encodedDateString = Globals.shared.encodeDate(date: sinceDate) {
            let urlString = cFormsURL + "/sync/" + encodedDateString
            loadList(url: URL(string: urlString), completion: completion)
        } else {
            FTErrorMessage(error: "Bad string for date")
        }
    }

    func saveAsForm(form: Template, completion : @escaping (_ result: [String : Any]?, _ error: String?)->()) {
        newTemplateForm(form: form, url: cFormsURL, successCode: 201, completion: completion)
    }

    // MARK: Locations  -------------------------------------------------------------------------------
    func loadLocations(completion : @escaping loadListCallback) {
        if let url = URL(string: cLocationsURL) {
            loadList(url: url, completion: completion)
        }
    }

    func syncLocations(sinceDate: Date, completion : @escaping loadListCallback) {
        if let encodedDateString = Globals.shared.encodeDate(date: sinceDate) {
            let urlString = cLocationsURL + "/sync/" + encodedDateString
            loadList(url: URL(string: urlString), completion: completion)
        } else {
            FTErrorMessage(error: "Bad string for date")
        }
    }

    class func createLocation(location: FTLocation, completion : @escaping (_ result: [String: Any]?, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let locationDict = location.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        Alamofire.request(cBaseURL + "/locations/", method: .post, parameters: locationDict, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if !response.result.isSuccess {
                completion(nil, "Failed to save location")
            } else {
                if let jsonData = response.data {
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                        if let locationDict = jsonDict as? [String: Any] {
                            completion(locationDict, nil)
                        }

                    } catch {
                        completion(nil, "Couldn't parse JSON: \(error)")
                    }
                }
            }
        })
    }

    class func updateLocation(location: FTLocation, completion : @escaping (_ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let locationDict = location.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        FTAssert(isTrue: location.id != "", error: "Trying to update location that wasn't saved")
        let url = cBaseURL + "/locations/" + location.id!
        Alamofire.request(url, method: .put, parameters: locationDict, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            completion(response.error?.localizedDescription)
        })
    }

    func deleteLocation(locationId: String, completion : @escaping (_ error : String?)->()) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = cLocationsURL + "/" + locationId
        Alamofire.request(url, method: .delete, parameters: ["id":locationId], encoding: JSONEncoding.default, headers: nil).responseString(completionHandler: { response in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            completion(response.error?.localizedDescription)
        })
    }

    // MARK: Images  -------------------------------------------------------------------------------
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
        FTAlertProgress(progress: 0.01, status: "Downloading photo")

        // SVProgressHUD is run from operations queue, so queue upload so it doesn't start until after alert is visible.
        OperationQueue.main.addOperation({
           let path = cDownloadPhotoURL + imageFileName
            _ = Just.get(path, params: [:], asyncProgressHandler: {(p) in
                FTAlertProgress(progress: p.percent, status: "Downloading photo")
            }) { (result) in
                FTAlertDismiss(completion: { 

                })
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
        var fileCount = mapArray.count
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
                            imageUpdate(map.resultIndex)
                        } else {
                            FTErrorMessage(error: "Server did not have image: \(map.fileName!)")
                        }
                    } else {
                        FTErrorMessage(error: result.error != nil ?  result.error!.localizedDescription : "Server did not have that image")
                    }
                    fileCount -= 1
                    if fileCount == 0 {
                        // Completely done, let view do full update
                        OperationQueue.main.addOperation({
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            return completion(nil)
                        })
                    }
                }
            })
        }
    }

    func uploadImages(photoFileList: PhotoFileList, completion : @escaping (_ photoFileList: PhotoFileList?, _ error: String?)->()) {
        // Start spinner
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FTAlertProgress(progress: 0.01, status: "Uploading photos")

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

            if let jsonDict = Just.post(cUploadPhotoURL, files: files, timeout:2.0, asyncProgressHandler: {(p) in
                FTAlertProgress(progress: p.percent, status: "Uploading photos")
            }).json {
                DispatchQueue.main.async() {
                    FTAlertDismiss(completion: {
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

    // Copys file names to form if successfull
    func uploadImagesWithoutUI(photoFileList: PhotoFileList, completion : @escaping (_ photoFileList: PhotoFileList?, _ error: String?)->()) {
        var files = [String:Data]()
        var fileIndex = 0
        for map in photoFileList.mapOfAllImages() {
            // Images saved to server are saved without proper orientation flag
            // This flag is not being saved to the exif data in the uploaded jpeg image, so make sure image is uploaded in
            // vertical orientation as that's what it will display in when read back.
            if let data = UIImagePNGRepresentation(map.image!.fixOrientation()) {
                files["\(fileIndex)"] = data //HTTPFile.data("\(fileIndex)", data, nil)
                fileIndex += 1
            }
        }

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in files {
                    multipartFormData.append(value, withName: key, fileName: key, mimeType: "image/jpeg")
                }
        }, to: cUploadPhotoURL,
        encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { progress in
                        debugPrint("Upload progress: \(progress)")
                    })
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            if let fileArray = value as? [Any]{
                                photoFileList.addNamesFromJson(fileArray: fileArray)
                                completion(photoFileList, nil)
                            }
                            print("responseObject: \(value)")
                        case .failure(let responseError):
                            print("responseError: \(responseError)")
                            completion(nil, "Couldn't upload images: \(responseError)")
                        }
                     }
                case .failure(let encodingError):
                    completion(nil, "Couldn't upload images: \(encodingError)")
                }
        })
//        if let jsonDict = Just.post(cUploadPhotoURL, files: files,  timeout:2.0, asyncProgressHandler: {(p) in
//            print("Uploading photos: \(p.percent)")
//        }).json {
//            if let fileArray = jsonDict as? [Any] {
//                photoFileList.addNamesFromJson(fileArray: fileArray)
//                completion(photoFileList, nil)
//            } else {
//                completion(nil, "Couldn't parse JSON")
//            }
 //       }
    }
}
