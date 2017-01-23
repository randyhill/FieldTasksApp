//
//  Globals.swift
//  FieldTasksApp
//
//  Created by CRH on 8/26/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit


class Globals {
    static let shared = Globals()
    var utcFormatter = DateFormatter()      // Convert UTC date strings
    var dateFormatter = DateFormatter()     // For visual display
    let smallFont = UIFont.flatFont(ofSize: 13.0)!
    let mediumFont = UIFont.flatFont(ofSize: 16.0)!
    let bigFont = UIFont.boldFlatFont(ofSize: 18.0)!
    let textColor = UIColor.clouds()
    let bgColor = UIColor.greenSea()

    init() {
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        UIBarButtonItem.configureFlatButtons(with: UIColor.belizeHole(), highlightedColor: UIColor.belizeHole(), cornerRadius: 3.0)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    func configureNavBar() {
        self.navigationController?.navigationBar.configureFlatNavigationBar(with: UIColor.midnightBlue())
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.clouds(), NSFontAttributeName : Globals.shared.bigFont]
        self.navigationController?.navigationBar.tintColor = UIColor.clouds()
    }
}

extension UITableViewCell {
    func configureDataCell() {
        configureFlatCell(with: UIColor.greenSea(), selectedColor: UIColor.clouds(), roundingCorners: .allCorners)
     }

    func configureHeaderCell() {
        configureFlatCell(with: UIColor.peterRiver(), selectedColor: UIColor.clouds(), roundingCorners: .allCorners)
        cornerRadius = 5.0
     }

    func addSeparator(y: CGFloat, margin: CGFloat, color: UIColor)
    {
        let sepFrame = CGRect(x: margin, y: self.frame.height - y, width: self.frame.width - margin, height: y);
        let seperatorView = UIView(frame: sepFrame);
        seperatorView.backgroundColor = color;
        self.addSubview(seperatorView);
    }
}
