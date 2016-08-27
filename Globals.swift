//
//  Globals.swift
//  FieldTasksApp
//
//  Created by CRH on 8/26/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit


class Globals {

}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}