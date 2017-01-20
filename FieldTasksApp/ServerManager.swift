//
//  ServerManager
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

#if LOCALHOST
let cBaseURL = "http://localhost:8080"
#else
let cBaseURL = "http://www.fieldtasks.co"
#endif

let cTemplatesURL = cBaseURL + "/templates"
let cFormsURL = cBaseURL + "/forms"


class ServerManager {
    static let sharedInstance = ServerManager()
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

    func saveTemplate(template: Template, completion : @escaping (_ result: Any?, _ error: String?)->()) {
        saveTemplateForm(form: template, url: cTemplatesURL, successCode: 200, completion: completion)
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

//    private func saveTemplateForm(form: Template, url: NSURL, successCode: Int, completion : @escaping (_ result: Any?, _ error: String?)->()) {
//        // Start spinner
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//
//        // Set headers
//        let request = NSMutableURLRequest(url: url as URL)
//        request.httpMethod = "POST"
//        request.timeoutInterval = 20.0
//        let formDict = form.toDict()
//        do {
//            let formData = try JSONSerialization.data(withJSONObject: formDict, options: JSONSerialization.WritingOptions())
//            request.httpBody = formData
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//            let dataTask = defaultSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
//                DispatchQueue.main.async() {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//                if let error = error {
//                    completion(nil, error.localizedDescription)
//                } else if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == successCode {
//                        if let jsonData = data {
//                            do {
//                                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
//                                completion(jsonDict, nil)
//
//                            } catch {
//                                completion(nil, "Couldn't parse JSON: \(error)")
//                            }
//
//                        }
//
//                    } else {
//                        completion(nil, "saveForm error: \(httpResponse.statusCode)")
//                    }
//                }
//            })
//            dataTask.resume()
//        } catch {
//            completion(nil, "exception error trying to save form: \(error)")
//        }
//    }
}
