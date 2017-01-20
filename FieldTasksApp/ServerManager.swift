//
//  ServerManager
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation
import UIKit

#if LOCALHOST
let cBaseURL = "http://localhost:8080"
//let cTemplatesURL = "http://localhost:8080/templates"
//let cFormsURL = "http://localhost:8080/forms"
#else
let cBaseURL = "http://www.fieldtasks.co"
//let cTemplatesURL ="http://www.fieldtasks.co/templates"
//let cFormsURL = "http://www.fieldtasks.co/forms"
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
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            let dataTask = defaultSession.dataTask(with: url as URL, completionHandler: { (data, response, error) in
//                DispatchQueue.main.async() {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//                if let error = error {
//                    completion(nil, error.localizedDescription)
//                } else if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == 200 {
//                        if let jsonData = data {
//                            do {
//                                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
//                                if let formList = jsonDict as? [AnyObject] {
//                                    completion(formList, nil)
//                                }
//
//                            } catch {
//                                completion(nil, "Couldn't parse JSON: \(error)")
//                            }
//
//                        }
//
//                    }
//                }
//            })
//            dataTask.resume()
        }
    }

    func loadForms(completion : @escaping (_ result: [AnyObject]?, _ error: String?)->()) {
        if let url = NSURL(string: cFormsURL) {
            loadList(url: url, completion: completion)
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            let dataTask = defaultSession.dataTask(with: url as URL, completionHandler: { (data, response, error) in
//                DispatchQueue.main.async() {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//                if let error = error {
//                    completion(nil, error.localizedDescription)
//                } else if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == 200 {
//                        if let jsonData = data {
//                            do {
//                                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
//                                if let formList = jsonDict as? [AnyObject] {
//                                    completion(formList, nil)
//                                }
//
//                            } catch {
//                                completion(nil, "Couldn't parse JSON: \(error)")
//                            }
//
//                        }
//
//                    }
//                }
//            })
//            dataTask.resume()
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

    func saveForm(form: Form, completion : @escaping (_ result: Any?, _ error: String?)->()) {
        if let url = NSURL(string: cFormsURL) {
            // Start spinner
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            // Set headers
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 20.0
            let formDict = form.toDict()
            do {
                let formData = try JSONSerialization.data(withJSONObject: formDict, options: JSONSerialization.WritingOptions())
                request.httpBody = formData

                let dataTask = defaultSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async() {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    if let error = error {
                        completion(nil, error.localizedDescription)
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 201 {
                            if let jsonData = data {
                                do {
                                    let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                                    completion(jsonDict, nil)

                                } catch {
                                    completion(nil, "Couldn't parse JSON: \(error)")
                                }
                                
                            }
                            
                        } else {
                            completion(nil, "saveForm error: \(httpResponse.statusCode)")
                        }
                    }
                })
                dataTask.resume()
            } catch {
                completion(nil, "exception error trying to save form: \(error)")
            }

        }
    }

    func saveTemplate(form: Template, completion : @escaping (_ result: Any?, _ error: String?)->()) {
        if let url = NSURL(string: cFormsURL) {
            // Start spinner
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            // Set headers
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 20.0
            let formDict = form.toDict()
            do {
                let formData = try JSONSerialization.data(withJSONObject: formDict, options: JSONSerialization.WritingOptions())
                request.httpBody = formData

                let dataTask = defaultSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
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
                                    completion(jsonDict, nil)

                                } catch {
                                    completion(nil, "Couldn't parse JSON: \(error)")
                                }

                            }

                        } else {
                            completion(nil, "saveForm error: \(httpResponse.statusCode)")
                        }
                    }
                })
                dataTask.resume()
            } catch {
                completion(nil, "exception error trying to save form: \(error)")
            }
            
        }
    }
}
