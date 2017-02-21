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

    init() {
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        UIBarButtonItem.configureFlatButtons(with: barButtonColor, highlightedColor: barButtonColor, cornerRadius: 3.0)
        SVProgressHUD.setMinimumDismissTimeInterval(3)

        // tab bar
        UITabBar.appearance().tintColor = barButtonColor
        UITabBar.appearance().barTintColor = UIColor.clouds()

    }
}

func FlatBarButton(title: String, target: Any?, action: Selector) -> UIBarButtonItem {
    let customButton = FUIButton(type: .custom)
    customButton.setTitle(title, for: .normal)
    customButton.setTitle(title, for: .highlighted)
    return customButton.makeFlatBarButton(target: target, action: action)
}

func FlatBarButton(withImageNamed: String, target: Any?, action: Selector) -> UIBarButtonItem {
    let customButton = FUIButton(type: .custom)
    let image = UIImage(named: withImageNamed)
    FTAssert(isTrue: image != nil, error: "Couldn't load button image: \(withImageNamed)")
    customButton.setImage(image, for: .normal)
    customButton.setImage(image, for: .normal)
    return customButton.makeFlatBarButton(target: target, action: action)
}

enum FTError : Error {
    case RunTimeError(String)
}

func FTAssert(isTrue: Bool, error: String, file: String = #file, line: Int = #line) {
    if !isTrue {
        FTErrorMessage(error: error, file: file, line: line)
    }
}

func FTErrorMessage(error: String, file: String = #file, line: Int = #line) {
    print("Assert failure - file: \(file) line: \(line) error:\(error)")
}


