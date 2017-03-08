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




