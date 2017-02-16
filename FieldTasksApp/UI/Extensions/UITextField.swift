//
//  UITextField.swift
//  FieldTasksApp
//
//  Created by CRH on 2/15/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit


extension UITextField {
//    func addDoneHideKeyboardButtons(title: String, target: Any?, completion : Selector) {
//        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//        doneToolbar.barStyle       = UIBarStyle.default
//        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        let done: UIBarButtonItem  = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.done, target: target, action: completion)
//        let hide: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.done, target: self, action: #selector(hideKeyboard))
//
//        var items = [UIBarButtonItem]()
//        items.append(hide)
//        items.append(flexSpace)
//        items.append(done)
//
//        doneToolbar.items = items
//        doneToolbar.sizeToFit()
//
//        self.inputAccessoryView = doneToolbar
//    }
    func addDoneHideKeyboardButtons(title: String, target: Any?, completion : Selector) {
        let barFrame = CGRect(x: 0, y: 0, width: 320, height: 50)
        let barItems = CreateKeyboardToolbarItems(barFrame: barFrame)

        let doneButton = CreateFlatBarButtonCustomView(title: "Done", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
        doneButton.addTarget(target, action: completion, for: .touchUpInside)
        barItems.doneItem.customView = doneButton

        let hideButton = CreateFlatBarButtonCustomView(title: "Hide", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
        hideButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        barItems.hideItem.customView = hideButton
        barItems.doneToolbar.sizeToFit()

        self.inputAccessoryView = barItems.doneToolbar
    }
    func hideKeyboard() {
        self.resignFirstResponder()
    }
}
