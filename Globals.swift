//
//  Globals.swift
//  FieldTasksApp
//                  Cache frequently used values for user's account.
//
//  Created by CRH on 8/26/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import SVProgressHUD
import SwiftDate

class Globals {
    static let shared = Globals()
    var utcFormatter = DateFormatter()      // Convert UTC date strings
    var dateFormatter = DateFormatter()     // For visual display
    var timeFormatter = DateFormatter()     // For visual display
    let smallFont = UIFont.flatFont(ofSize: 13.0)!
    let mediumFont = UIFont.flatFont(ofSize: 16.0)!
    let bigFont = UIFont.boldFlatFont(ofSize: 18.0)!
    let textColor = UIColor.clouds()
    let bgColor = UIColor.greenSea()
    let barColor = UIColor.asbestos()
    let barButtonColor = UIColor.peterRiver()
    let selectionColor = UIColor.wetAsphalt()

    // MARK: Login Tokens  -------------------------------------------------------------------------------
    private var _login : Login?
    private var login : Login {
        get {
            if let login = _login {
                return login
            } else {
                _login = CoreDataMgr.fetchLogin(context: CoreDataMgr.shared.mainThreadContext!)
                 return _login!
            }
        }
    }
    var loginToken : String {
        get {
            let login = self.login
            return login.token ?? ""
        }
    }
    var loginEmail : String {
        get {
            // We'll use
            let login = self.login
            return login.email ?? ""
        }
        set(newEmail) {
            let login = self.login
            login.email = newEmail
        }
    }
    var tenantName : String {
        get {
            let login = self.login
            return login.tenant ?? ""
        }
        set(newTenant) {
            let login = self.login
            login.tenant = newTenant
        }
    }
    var tokenExpired : Bool {
        get {
            let login = self.login
            if let expiration = login.expiration {
                let dateTimeStamp = Date(timeIntervalSince1970: TimeInterval(truncating: expiration))
                return Date().timeIntervalSince(dateTimeStamp) > 0
            }
            return true
        }
    }

    func setToken(token : String, expiration: Int64, email: String, tenant: String) {
        let login = self.login
        login.token = token
        login.expiration = expiration as NSNumber
        login.email = email
        login.tenant = tenant
        CoreDataMgr.shared.saveOnMainThread()
    }

    func clearToken() {
        login.token = nil
        login.expiration = 0
        CoreDataMgr.shared.saveOnMainThread()
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: cAppLoggedOut)))
    }

    init() {
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .long

        UIBarButtonItem.configureFlatButtons(with: barButtonColor, highlightedColor: barButtonColor, cornerRadius: 3.0)
        SVProgressHUD.setMinimumDismissTimeInterval(3)

        // tab bar
        UITabBar.appearance().tintColor = UIColor.clouds()
        UITabBar.appearance().barTintColor = UIColor.peterRiver()

        // Text
        UITextField.appearance().tintColor = UIColor.midnightBlue()
        UITextView.appearance().tintColor = UIColor.midnightBlue()
    }

    class func saveSettingsValue(key: String, value: AnyObject) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    class func getSettingsValue(key: String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }

    // MARK: Dates  -------------------------------------------------------------------------------
    func encodeDate(date: Date) -> String? {
        let dateString = utcFormatter.string(from: date)
        return dateString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    func formatDate(date: Date) -> String {
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    func formatTime(date: Date) -> String {
        let timeString = timeFormatter.string(from: date)
        return timeString
    }

    private func _stringToDate(dateString: String, format: String ) -> Date? {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: dateString) {
            return Date(timeInterval:0, since:d)
        }
        return nil
    }

    func stringToDate(dateString: String) -> Date? {
        return _stringToDate(dateString: dateString, format: "yyyy-MM-dd")
    }

    func serverStringToDate(dateString: String) -> Date? {
        return _stringToDate(dateString: dateString, format: "E, dd MMM yyyy HH:mm:ss zzz")
   }
}

// MARK: Files  -------------------------------------------------------------------------------
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

// Use caches directly for images. this means that we need to make sure images are uploaded to server before placed here so they aren't lost.
func getImageDirectory() -> URL {
    let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func randomName(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

func className(object: Any) -> String {
    return (object is Any.Type) ? "\(object)" : "\(type(of: object))"
}


// MARK: Error Asserts  -------------------------------------------------------------------------------
enum FTError : Error {
    case RunTimeError(String)
}

func FTAssert(isTrue: Bool, error: String, method: String = #function, line: Int = #line) {
    if !isTrue {
        FTErrorMessage(error: error, method: method, line: line)
    }
}

func FTAssert(exists: Any?, error: String, method: String = #function, line: Int = #line) {
    if exists == nil {
        FTErrorMessage(error: error, method: method, line: line)
    }
}


func FTAssertString(error: String?, method: String = #function, line: Int = #line) {
    if let error = error {
        FTErrorMessage(error: error, method: method, line: line)
    }
}

func FTErrorMessage(error: String, method: String = #function, line: Int = #line) {
    print("Assert failure: \(error) - \(method):\(line)")
}

func FTPrint(s: String, method: String = #function, line: Int = #line) {
    let nowString = Globals.shared.formatTime(date: Date())
    print(s + " : " + nowString)
}



