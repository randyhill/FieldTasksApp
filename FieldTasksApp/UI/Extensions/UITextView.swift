//
//  UITextView.swift
//  FieldTasksApp
//
//  Created by CRH on 2/8/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

// Create keyboard toobar button with FlatUI so it can be shared among multiple extensions
func CreateFlatBarButtonCustomView(title: String, buttonFrame: CGRect) -> FUIButton {
    let button = FUIButton(type: .custom)
    button.setTitle(title, for: .normal)
    button.setTitle(title, for: .highlighted)
    button.frame = buttonFrame
    button.makeFlatButton()
    return button
}

// Create keyboard toolbar so it can be shared among multiple extensions
func CreateKeyboardToolbarItems(barFrame: CGRect) -> (hideItem: UIBarButtonItem, doneItem: UIBarButtonItem, doneToolbar: UIToolbar) {
    let doneToolbar: UIToolbar = UIToolbar(frame: barFrame)
    doneToolbar.barStyle       = UIBarStyle.default
    let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    let doneItem: UIBarButtonItem  = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: nil, action: nil)
    let hideItem: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.done, target: nil, action: nil)

    var items = [UIBarButtonItem]()
    items.append(hideItem)
    items.append(flexSpace)
    items.append(doneItem)
    doneToolbar.items = items

    return (doneItem: doneItem, hideItem: hideItem, doneToolbar: doneToolbar)
}

extension UITextView {
    // Styles
    func makeFlatTextView() {
        self.layer.borderWidth =  1.0
        self.font = Globals.shared.mediumFont
        self.backgroundColor = UIColor.clouds()
    }

    func makeTitleStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.boldFlatFont(ofSize: 17)
    }

    func makeDetailStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.flatFont(ofSize: 14)
    }

    func setActiveStyle(isActive : Bool) {
        if isActive {
            self.backgroundColor = UIColor.clouds()
        } else {
            self.backgroundColor = UIColor.silver()
        }
        self.textColor = UIColor.wetAsphalt()
        self.font = UIFont.boldFlatFont(ofSize: 17)
        self.isEditable = isActive
    }

    // Keyboard
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
