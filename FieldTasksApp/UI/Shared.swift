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

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

// Use caches directly for images. this means that we need to make sure images are uploaded to server before placed here so they aren't lost.
func getImageDirectory() -> URL {
    let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
   // return documentsDirectory.appendingPathComponent("images")
}

func randomFileName() -> String {
    let length = cFileNameLength
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

func className(object: Any) -> String {
    return (object is Any.Type) ? "\(object)" : "\(type(of: object))"
}

func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
    return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
}

func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
    UIApplication.shared.endBackgroundTask(taskID)
}

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

func FTAssert(isTrue: Bool, error: String, method: String = #function, line: Int = #line) {
    if !isTrue {
        FTErrorMessage(error: error, method: method, line: line)
    }
}

func FTAssert(exists: Any?, error: String, method: String = #function, line: Int = #line) {
    if exists == nil {
        FTErrorMessage(error: error, method: method, line: line)
    }
}


func FTAssertString(error: String?, method: String = #function, line: Int = #line) {
    if let error = error {
        FTErrorMessage(error: error, method: method, line: line)
    }
}

func FTErrorMessage(error: String, method: String = #function, line: Int = #line) {
    print("Assert failure: \(error) - \(method):\(line)")
}

func FTPrint(s: String, method: String = #function, line: Int = #line) {
    let nowString = Globals.shared.formatTime(date: Date())
    print(s + " : " + nowString + " \(method): \(line)")
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
