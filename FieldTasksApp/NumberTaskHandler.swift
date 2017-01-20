//
//  NumberTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit


class NumberTaskHandler : TextTaskHandler {
    var rangeLabel = UILabel()
    var taskData : NumberTaskDescription {
        get {
            return task!.taskDescription as! NumberTaskDescription
        }
    }
    var numberResult : NumberResult {
        get {
            return task!.result as! NumberResult
        }
    }

    override func configureTextView(container : UIView) {
        textView.frame.size.height = 28.0
        if !taskData.isUnlimited {
            // Describe range to users
            rangeLabel.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.height, width: textView.frame.width, height: 28)
            //(textView.frame.origin.x, textView.frame.height, textView.frame.width, 28)
            rangeLabel.text = "Range: \(taskData.min) to \(taskData.max)"
            container.addSubview(rangeLabel)
        }
        if taskData.isDecimal {
            textView.keyboardType = .decimalPad
        } else {
            textView.keyboardType = .numberPad
        }
        textView.text = String(describing: numberResult.value)
        textView.becomeFirstResponder()
    }

    override func validate() -> String? {
        guard let text = textView.text, let value = Float(text) else {
            return "No number value entered"
        }
        if taskData.isUnlimited {
            return nil
        }
        if value < Float(taskData.min) {
            return "Value less than minimum allowed"
        }
        if value > Float(taskData.max) {
            return "Value more than maximum allowed"
        }
        return nil
    }
    override func save() {
        numberResult.save(newText: textView.text)
    }
    override func restore() {
        if let value = numberResult.value {
            textView.text = String(value)
        } else {
            textView.text = ""
        }
    }
}
