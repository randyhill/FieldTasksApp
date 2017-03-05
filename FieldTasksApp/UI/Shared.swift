//
//  Shared.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import SVProgressHUD

let cTitleFontSize = CGFloat(16.0)
let cDetailFontSize = CGFloat(13.0)

func FlatBarButton(title: String, target: Any?, action: Selector) -> UIBarButtonItem {
    let customButton = FUIButton(type: .custom)
    customButton.setTitle(title, for: .normal)
    customButton.setTitle(title, for: .highlighted)
    return customButton.makeFlatBarButton(target: target, action: action)
}

func FlatBarButton(withImageNamed: String, target: Any?, action: Selector) -> UIBarButtonItem {
    let customButton = FUIButton(type: .custom)
    let image = UIImage(named: withImageNamed)
    FTAssert(isTrue: image != nil, error: "Couldn't load button image: \(withImageNamed)")
    customButton.setImage(image, for: .normal)
    customButton.setImage(image, for: .normal)
    return customButton.makeFlatBarButton(target: target, action: action)
}

enum FTError : Error {
    case RunTimeError(String)
}

func FTAssert(isTrue: Bool, error: String, file: String = #file, line: Int = #line) {
    if !isTrue {
        FTErrorMessage(error: error, file: file, line: line)
    }
}

func FTAssertString(error: String?, file: String = #file, line: Int = #line) {
    if let error = error {
        FTErrorMessage(error: error, file: file, line: line)
    }
}

func FTErrorMessage(error: String, file: String = #file, line: Int = #line) {
    print("Assert failure - file: \(file) line: \(line) error:\(error)")
}

func FTAlertMessage(message: String) {
    SVProgressHUD.showInfo(withStatus: message)
}

func FTAlertError(message: String) {
    SVProgressHUD.showError(withStatus: message)
}

func FTAlertSuccess(message: String) {
    SVProgressHUD.showSuccess(withStatus: message)
}

func FTAlertProgress(progress: Float, status: String) {
    SVProgressHUD.showProgress(progress, status: status)
}

func FTAlertDismiss(completion: @escaping ()->() ) {
    SVProgressHUD.dismiss {
        completion()
    }
}
