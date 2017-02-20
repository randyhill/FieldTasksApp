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
    @IBOutlet weak var rangeHeight: NSLayoutConstraint!

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
            rangeLabel.text = "Range: \(taskData.minString) to \(taskData.maxString)"
            rangeLabel.isHidden = false
            rangeHeight.constant = rangeLabel.sizeThatFits(rangeLabel.bounds.size).height
        } else {
            rangeLabel.isHidden = true
            rangeHeight.constant = 0
        }
        if taskData.isDecimal {
            numberField.keyboardType = .decimalPad
        } else {
            numberField.keyboardType = .numberPad
        }
        numberField.addDoneHideKeyboardButtons(title: "Done", target: self, completion: #selector(doneButtonAction))
        numberField.becomeFirstResponder()
        numberField.font = Globals.shared.mediumFont
        rangeLabel.makeTitleStyle()
    }

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        rangeLabel.isHidden = true
//    }

    func doneButtonAction() {
        self.save()
        parentController?.dismiss(animated: true, completion: nil)
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
        numberField.resignFirstResponder()
        rangeLabel.isHidden = true
    }

    private func setNumberValue() {
        numberField.text = numberResult.description()
    }

    override func restore() {
        setNumberValue()
    }
}
