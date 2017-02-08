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
    let barButtonColor = UIColor.belizeHole()

    init() {
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        UIBarButtonItem.configureFlatButtons(with: barButtonColor, highlightedColor: barButtonColor, cornerRadius: 3.0)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
    }
}

enum FTError : Error {
    case RunTimeError(String)
}


