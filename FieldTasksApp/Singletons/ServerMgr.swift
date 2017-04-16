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
import AWSS3
import AWSDynamoDB
import AWSSQS
import AWSSNS
import AWSCognito

#if LOCALHOST
let cBaseURL = "http://localhost:8080"
#else
let cBaseURL = "http://www.fieldtasks.co"
#endif

let cAPI_URL = cBaseURL + "/api"
let cTemplatesURL = cAPI_URL + "/templates"
let cFormsURL = cAPI_URL + "/forms"//let cAllFormsURL = cAPI_URL + "/allforms"
let cLocationsURL = cAPI_URL + "/locations"
let cLocationTemplatesURL = cAPI_URL + "/locations/templates"
let cS3Bucket = "com.fieldtasks.images"
let cFileNameLength = 12

class ServerMgr {
    static let shared = ServerMgr()
    let transferManager = AWSS3TransferManager.default()

    init() {
    }

    // 403 codes mean our token has expired/been blacklisted.
    func check(statusCode : Int?) {
        if let statusCode = statusCode {
            if statusCode == 403 {
                Globals.shared.clearToken()
            }
        }
    }

//    func apiHeaders() -> HTTPHeaders {
//        let token = Globals.shared.loginToken
//        let headers: HTTPHeaders = [
//            "Accept": "application/json",
//            "token" : token,
//            "tenant" : Globals.shared.tenantName
//        ]
//        return headers
//    }

    func createURLRequest(urlPath: String, method: HTTPMethod, parameters: [String : Any]?) -> URLRequest {
        let url = URL(string: urlPath)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                FTErrorMessage(error: error.localizedDescription)
            }
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(Globals.shared.loginToken, forHTTPHeaderField: "token")
        urlRequest.setValue(Globals.shared.tenantName, forHTTPHeaderField: "tenant")
       return urlRequest
    }

    // MARK: Sync All -------------------------------------------------------------------------------
    // Get all synced objects at once, returns new/modified/deleted Templates/Forms/Locations in JSON dictionary
    func syncAll(sinceDate: Date, completion : @escaping (_ result: [String: Any]?, _ timeStamp: Date?,  _ error: String?)->()) {
        guard let encodedDateString = Globals.shared.encodeDate(date: sinceDate) else {
            FTErrorMessage(error: "Date string could not be encoded")
            return
        }
        Alamofire.request(createURLRequest(urlPath: cAPI_URL + "/sync/" + encodedDateString, method: .get, parameters: nil)).responseJSON { (response) in
            self.check(statusCode: response.response?.statusCode)
            if response.result.isSuccess && response.response?.statusCode == 200, let jsonData = response.data {
                do {
                    // If we can't parse server timestamp just use now
                    let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                    if let jsonDict = jsonDict as? [String: Any]{
                        var timeStamp = Date()
                        if let timeStampString = response.response?.allHeaderFields["Date"] as? String, let serverDate =  Globals.shared.serverStringToDate(dateString: timeStampString) {
                            timeStamp =  serverDate
                        }
                        completion(jsonDict, timeStamp, nil)
                    }
                } catch {
                    completion(nil, nil, "Couldn't parse JSON")
                }
            }
        }
    }

    func newTemplateForm(form: Template, url: String, successCode: Int, completion : @escaping (_ result: [String: Any]?, _ error: String?)->()) {
        // Start spinner
        let formDict = form.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        let url = url + "/"
        Alamofire.request(createURLRequest(urlPath: url, method: .post, parameters: formDict)).responseJSON { (response) in
            self.check(statusCode: response.response?.statusCode)
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
        }
    }

    private func saveTemplateForm(form: Template, url: String, successCode: Int, completion : @escaping (_ error: String?)->()) {
        let formDict = form.toDict()

        let url = url + "/" + form.id!
        Alamofire.request(createURLRequest(urlPath: url, method: .put, parameters: formDict)).responseJSON { (response) in
            self.check(statusCode: response.response?.statusCode)
            completion(response.result.isSuccess ? nil : "Failed to save form")
        }
    }

    // MARK: Templates Methods -------------------------------------------------------------------------------
    func deleteTemplate(templateId: String, completion : @escaping (_ statusCode: Int?, _ error : String?)->()) {
        let url = cTemplatesURL + "/" + templateId
        Alamofire.request(createURLRequest(urlPath: url, method: .delete, parameters: ["id":templateId])).responseString { (response) in
            self.check(statusCode: response.response?.statusCode)
            let statusCode = response.response?.statusCode
            completion(statusCode, response.error?.localizedDescription)
        }
    }

    func newTemplate(template: Template, completion : @escaping (_ result: [String : Any]?, _ error: String?)->()) {
        newTemplateForm(form: template, url: cTemplatesURL, successCode: 201, completion: completion)
    }

    func saveTemplate(template: Template, completion : @escaping (_ error: String?)->()) {
        saveTemplateForm(form: template, url: cTemplatesURL, successCode: 201, completion: completion)
    }

    // MARK: Forms Methods -------------------------------------------------------------------------------

    func saveAsForm(form: Template, completion : @escaping (_ result: [String : Any]?, _ error: String?)->()) {
        newTemplateForm(form: form, url: cFormsURL, successCode: 201, completion: completion)
    }

    // MARK: Locations  -------------------------------------------------------------------------------

    func createLocation(location: FTLocation, completion : @escaping (_ result: [String: Any]?, _ error: String?)->()) {
        let locationDict = location.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        Alamofire.request(self.createURLRequest(urlPath: cLocationsURL, method: .post, parameters: locationDict)).responseJSON { (response) in
            if !response.result.isSuccess {
                self.check(statusCode: response.response?.statusCode)
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
        }
    }

    func updateLocation(location: FTLocation, completion : @escaping (_ error: String?)->()) {
        let locationDict = location.toDict()

        // for some reason POST requests require the path to end with / or the server will redirect to GET
        FTAssert(isTrue: location.id != "", error: "Trying to update location that wasn't saved")
        let url = cLocationsURL + "/" + location.id!
        Alamofire.request(createURLRequest(urlPath: url, method: .put, parameters: locationDict)).responseJSON { (response) in
            self.check(statusCode: response.response?.statusCode)
            completion(response.error?.localizedDescription)
        }
    }

    func deleteLocation(locationId: String, completion : @escaping (_ statusCode: Int?, _ error : String?)->()) {
        let url = cLocationsURL + "/" + locationId
        Alamofire.request(createURLRequest(urlPath: url, method: .delete, parameters: ["id":locationId])).responseJSON { (response) in
            self.check(statusCode: response.response?.statusCode)
            let statusCode = response.response?.statusCode
            completion(statusCode, response.error?.localizedDescription)
        }
    }

    // MARK: Image Files  -------------------------------------------------------------------------------
    func imageAWSPath(fileName : String) -> String {
       return Globals.shared.tenantName + "/" + fileName
    }
    func uploadImage(fileName: String, progress : @escaping (Float)->(), completion : @escaping (_ fileName: String, _ error: String?)->()) {
        let localPath = getImageDirectory().appendingPathComponent(fileName)
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = cS3Bucket
            uploadRequest.key = imageAWSPath(fileName: fileName)
            uploadRequest.body = localPath
            uploadRequest.uploadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
                let progressValue = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                progress(progressValue)
            }
            transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                if let error = (task.error as NSError?) {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            completion("", "Error uploading: \(fileName) Error: \(error)")
                        }
                    } else {
                        completion("", "Error uploading: \(fileName) Error: \(error)")
                    }
                } else {
                    completion(fileName, nil)
                }
                return nil
            })
        } else {
            FTPrint(s: "Couldn't load AWS Transfer Manager to upload image")
            completion("", "Couldn't load AWS Transfer Manager to upload image")
        }

    }

    func downloadImage(fileName : String, progress: @escaping (_ progress: Float)->(), completion : @escaping (_ image : UIImage?, _ error: String?)->()) {
        // get a client with the default service configuration
        let downloadingFileURL = getImageDirectory().appendingPathComponent(fileName)
        if let downloadRequest = AWSS3TransferManagerDownloadRequest() {
            downloadRequest.bucket = cS3Bucket
            downloadRequest.key = imageAWSPath(fileName: fileName)
            downloadRequest.downloadingFileURL = downloadingFileURL
            downloadRequest.downloadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
                let progressValue = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                progress(progressValue)
            }
            transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                if let error = (task.error as NSError?) {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            completion(nil, "Error downloading: \(fileName) Error: \(error)")
                        }
                    } else {
                        completion(nil, "Error downloading: \(fileName) Error: \(error)")
                    }
                } else {
                    print("Download complete for: \(fileName)")
                    if let image = UIImage(contentsOfFile: downloadingFileURL.path) {
                        completion(image, nil)
                    }
                }
                return nil
            })
        }
    }
    
    // MARK: Login  -------------------------------------------------------------------------------
    func login(tenant: String, accountEmail : String, password: String, completion: @escaping (_ dict: [String:Any]?, _ error: String?)->()) {
        let parameters = ["email" : accountEmail, "password" : password, "tenant": tenant]
        Alamofire.request(cBaseURL + "/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200..<201).responseJSON(completionHandler: { response in
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                let error = statusCode == 401 ? "Login Failed: Could not find user" : "Login failed: Unknown error"
                completion(nil, error)
            } else {
                if let jsonData = response.data {
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                        if let dict = jsonDict as? [String: Any] {
                            completion(dict, nil)
                        }
                    } catch {
                        completion(nil, "Couldn't parse JSON: \(error)")
                    }
                }
            }
        })
    }

    func revokeToken() {
        Alamofire.request(createURLRequest(urlPath: cAPI_URL + "/revokeToken", method: .post, parameters: nil)).validate(statusCode: 200..<201).responseJSON(completionHandler: { response in
            print(response)
        })
    }
}
