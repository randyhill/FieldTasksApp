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
func CreateDoneHideItems(barFrame: CGRect) -> (hideItem: UIBarButtonItem, doneItem: UIBarButtonItem, doneToolbar: UIToolbar) {
    let doneToolbar: UIToolbar = UIToolbar(frame: barFrame)
    doneToolbar.barStyle       = UIBarStyle.default
    let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let doneItem: UIBarButtonItem  = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.done, target: nil, action: nil)
    let hideItem: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItem.Style.done, target: nil, action: nil)

    var items = [UIBarButtonItem]()
    items.append(hideItem)
    items.append(flexSpace)
    items.append(doneItem)
    doneToolbar.items = items

    return (doneItem: doneItem, hideItem: hideItem, doneToolbar: doneToolbar)
}

func CreateDoneHideKeyboardBar(title: String, target: Any?, completion : Selector, textView: Any?, hide: Selector) -> UIToolbar {
    let barFrame = CGRect(x: 0, y: 0, width: 320, height: 50)
    let barItems = CreateDoneHideItems(barFrame: barFrame)

    let doneButton = CreateFlatBarButtonCustomView(title: "Done", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
    doneButton.addTarget(target, action: completion, for: .touchUpInside)
    barItems.doneItem.customView = doneButton

    let hideButton = CreateFlatBarButtonCustomView(title: "Hide", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
    hideButton.addTarget(textView, action: hide, for: .touchUpInside)
    barItems.hideItem.customView = hideButton
    barItems.doneToolbar.sizeToFit()

    return barItems.doneToolbar
}

func CreateKeyboardHideItem(barFrame: CGRect) -> (hideItem: UIBarButtonItem, doneToolbar: UIToolbar) {
    let doneToolbar: UIToolbar = UIToolbar(frame: barFrame)
    doneToolbar.barStyle       = UIBarStyle.default
    let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let hideItem: UIBarButtonItem  = UIBarButtonItem(title: "Hide", style: UIBarButtonItem.Style.done, target: nil, action: nil)

    var items = [UIBarButtonItem]()
    items.append(hideItem)
    items.append(flexSpace)
    doneToolbar.items = items
    return (hideItem: hideItem, doneToolbar: doneToolbar)
}

func CreateHideKeyboardBar(textView: UIView, selector: Selector) -> UIToolbar {
    let barFrame = CGRect(x: 0, y: 0, width: 320, height: 50)
    let barItems = CreateKeyboardHideItem(barFrame: barFrame)

    let hideButton = CreateFlatBarButtonCustomView(title: "Hide", buttonFrame: CGRect(x: barFrame.width - 80, y: 10, width: 70, height: 30))
    hideButton.addTarget(textView, action: selector, for: .touchUpInside)
    barItems.hideItem.customView = hideButton
    barItems.doneToolbar.sizeToFit()

    return barItems.doneToolbar
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
        self.font = UIFont.boldFlatFont(ofSize: cTitleFontSize)
    }

    func makeDetailStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.flatFont(ofSize: cDetailFontSize)
    }

    func setActiveStyle(isActive : Bool) {
        if isActive {
            self.backgroundColor = UIColor.clouds()
        } else {
            self.backgroundColor = UIColor.silver()
        }
        self.textColor = UIColor.wetAsphalt()
        self.font = UIFont.boldFlatFont(ofSize: 15)
        self.isEditable = isActive
    }

    // Keyboard
    func addDoneHideKeyboardButtons(title: String, target: Any?, completion : Selector) {
        self.inputAccessoryView = CreateDoneHideKeyboardBar(title: title, target: target, completion: completion, textView: self, hide: #selector(hideKeyboard))
    }

    func addHideKeyboardButton() {
        self.inputAccessoryView =  CreateHideKeyboardBar(textView: self, selector: #selector(hideKeyboard))
    }

    @objc func hideKeyboard() {
        self.resignFirstResponder()
    }
}
