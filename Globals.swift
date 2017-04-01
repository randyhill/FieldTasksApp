//
//  Globals.swift
//  FieldTasksApp
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

func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
    return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
}

func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
    UIApplication.shared.endBackgroundTask(taskID)
}

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



