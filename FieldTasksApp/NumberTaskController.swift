//
//  NumberTaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class NumberTaskController : TaskController {
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var rangeLabel: UILabel!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        if !taskData.isUnlimited {
            rangeLabel.text = "Range: \(taskData.min) to \(taskData.max)"
            rangeLabel.isHidden = false
        } else {
            rangeLabel.isHidden = true
        }
        if taskData.isDecimal {
            numberField.keyboardType = .decimalPad
        } else {
            numberField.keyboardType = .numberPad
        }
        numberField.becomeFirstResponder()
        numberField.font = Globals.shared.mediumFont
    }

    override func validate() -> String? {
        guard let text = numberField.text, let value = Float(text) else {
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
        numberResult.save(newText: numberField.text!)
    }

    private func setNumberValue() {
        if taskData.isDecimal {
            numberField.text = String(describing: numberResult.value)
        } else {
            if let numberValue = numberResult.value {
                numberField.text = String(describing: Int(numberValue))
            } else {
                numberField.text = ""
            }
        }
    }

    override func restore() {
        setNumberValue()
    }
}
