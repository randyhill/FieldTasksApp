//
//  ServerManager
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation
import UIKit

#if LOCAL
let cGetTemplatesURL = "http://localhost:8080/templates"
let cSaveFormsURL = "http://localhost:8080/forms"
#else
let cGetTemplatesURL = "https://protected-ridge-16932.herokuapp.com/templates"
let cSaveFormsURL = "https://protected-ridge-16932.herokuapp.com/forms"
#endif

class ServerManager {
    static let sharedInstance = ServerManager()
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    init() {

    }

    func loadForms(completion : (result: [AnyObject]?, error: String?)->()) {
        if let url = NSURL(string: cGetTemplatesURL) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let dataTask = defaultSession.dataTaskWithURL(url, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                if let error = error {
                    completion(result: nil, error: error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let jsonData = data {
                            do {
                                let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                                if let formList = jsonDict as? [AnyObject] {
                                    completion(result: formList, error: nil)
                                }

                            } catch {
                                print("JSON threw error: \(error)")
                                completion(result: nil, error: "Couldn't parse JSON")
                            }

                        }

                    }
                }
            })
            dataTask.resume()
        }
    }

    func saveForm(form: Form, completion : (result: [AnyObject]?, error: String?)->()) {
        if let url = NSURL(string: cSaveFormsURL) {
            // Start spinner
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true

            // Set headers
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 20.0
            let formDict = form.toDict()
            do {
                let formData = try NSJSONSerialization.dataWithJSONObject(formDict, options: NSJSONWritingOptions())
                request.HTTPBody = formData

                let dataTask = defaultSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    dispatch_async(dispatch_get_main_queue()) {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    if let error = error {
                        completion(result: nil, error: error.localizedDescription)
                    } else if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let jsonData = data {
                                do {
                                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                                    if let formList = jsonDict as? [AnyObject] {
                                        completion(result: formList, error: nil)
                                    }

                                } catch {
                                    print("JSON threw error: \(error)")
                                    completion(result: nil, error: "Couldn't parse JSON")
                                }
                                
                            }
                            
                        } else {
                            print("saveForm error: \(httpResponse.statusCode)")
                        }
                    }
                })
                dataTask.resume()
            } catch {
                print("exception error trying to save form: \(error)")
            }

        }
    }
}