//
//  NumberTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

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
            rangeLabel.text = "Range: \(taskData.min) to \(taskData.max)"
            container.addSubview(rangeLabel)
        }
        if taskData.isDecimal {
            textView.keyboardType = .decimalPad
 //           textView.text = String(describing: numberResult.value)
        } else {
            textView.keyboardType = .numberPad
//            if let numberValue = numberResult.value {
//                textView.text = String(describing: Int(numberValue))
//            }
        }
        textView.isEditable = isEditable
        textView.becomeFirstResponder()
        textView.font = Globals.shared.mediumFont
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

    private func setNumberValue() {
        if taskData.isDecimal {
            textView.text = String(describing: numberResult.value)
        } else {
            if let numberValue = numberResult.value {
                textView.text = String(describing: Int(numberValue))
            } else {
                textView.text = ""
            }
        }
    }

    override func restore() {
        setNumberValue()
    }
}
