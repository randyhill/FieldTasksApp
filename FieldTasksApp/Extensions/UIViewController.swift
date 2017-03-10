//
//  UIViewController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/5/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    func askAlert(title : String, body: String, action: String, cancel: String = "Cancel", completion: @escaping (_ canceled: Bool)->()) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
            completion(false)
        }))
        alert.addAction( UIAlertAction(title: action, style: .destructive, handler: { (action) in
            completion(true)
        }))
        self.present(alert, animated: true, completion: {

        })
    }

    func makeNavBarFlat() {
        self.navigationController?.navigationBar.configureFlatNavigationBar(with: UIColor.belizeHole())//Globals.shared.barColor)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.clouds(), NSFontAttributeName : Globals.shared.bigFont]
        self.navigationController?.navigationBar.tintColor = UIColor.clouds()
    }
}
