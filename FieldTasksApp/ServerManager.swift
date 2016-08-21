//
//  ServerManager
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import Foundation
import UIKit



class ServerManager {
    static let sharedInstance = ServerManager()
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    init() {

    }

    func loadForms(completion : (result: [AnyObject]?, error: String?)->()) {
        if let url = NSURL(string: "https://protected-ridge-16932.herokuapp.com/forms") {
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
                                    print("success")
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
}