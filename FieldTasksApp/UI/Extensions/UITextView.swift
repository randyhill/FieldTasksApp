//
//  UITextView.swift
//  FieldTasksApp
//
//  Created by CRH on 2/8/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

extension UITextView {
    func makeTitleStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.boldFlatFont(ofSize: 17)
    }

    func makeDetailStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.flatFont(ofSize: 14)
    }
    func addKeyboardButton(title: String, target: Any?, completion : Selector) {
         let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.done, target: target, action: completion)

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}

extension UITextField {
    func addDoneHideKeyboardButtons(title: String, target: Any?, completion : Selector) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.done, target: target, action: completion)
        let hide: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.done, target: self, action: #selector(hideKeyboard))

        var items = [UIBarButtonItem]()
        items.append(done)
        items.append(flexSpace)
        items.append(hide)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
    func hideKeyboard() {
        self.resignFirstResponder()
    }
}
