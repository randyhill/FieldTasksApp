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

    func makeNavBarFlat() {
        self.navigationController?.navigationBar.configureFlatNavigationBar(with: Globals.shared.barColor)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.clouds(), NSFontAttributeName : Globals.shared.bigFont]
        self.navigationController?.navigationBar.tintColor = UIColor.clouds()
    }
}
