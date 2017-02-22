//
//  UITextField.swift
//  FieldTasksApp
//
//  Created by CRH on 2/15/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

func CreateKeyboardHideItem(barFrame: CGRect) -> (hideItem: UIBarButtonItem, doneToolbar: UIToolbar) {
    let doneToolbar: UIToolbar = UIToolbar(frame: barFrame)
    doneToolbar.barStyle       = UIBarStyle.default
    let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    let hideItem: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.done, target: nil, action: nil)

    var items = [UIBarButtonItem]()
    items.append(hideItem)
    items.append(flexSpace)
    doneToolbar.items = items
    return (hideItem: hideItem, doneToolbar: doneToolbar)
}

extension UITextField {
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

    func addHideKeyboardButton() {
        let barFrame = CGRect(x: 0, y: 0, width: 320, height: 50)
        let barItems = CreateKeyboardHideItem(barFrame: barFrame)

        let hideButton = CreateFlatBarButtonCustomView(title: "Hide", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
        hideButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        barItems.hideItem.customView = hideButton
        barItems.doneToolbar.sizeToFit()

        self.inputAccessoryView = barItems.doneToolbar
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
    }
}
