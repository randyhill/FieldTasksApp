//
//  UITextField.swift
//  FieldTasksApp
//
//  Created by CRH on 2/15/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

extension UITextField {
    func addDoneHideKeyboardButtons(title: String, target: Any?, completion : Selector) {
        self.inputAccessoryView = CreateDoneHideKeyboardBar(title: title, target: target, completion: completion, textView: self, hide: #selector(hideKeyboard))
    }

    func addHideKeyboardButton() {
        self.inputAccessoryView =  CreateHideKeyboardBar(textView: self, selector: #selector(hideKeyboard))
    }

    internal func hideKeyboard() {
        self.resignFirstResponder()
    }

    func setActiveStyle(isActive : Bool) {
        if isActive {
            self.backgroundColor = UIColor.clouds()
        } else {
            self.backgroundColor = UIColor.silver()
        }
        self.textColor = UIColor.wetAsphalt()
        self.font = UIFont.boldFlatFont(ofSize: 15)
        self.isEnabled = isActive
    }
}
