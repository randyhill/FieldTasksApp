//
//  NumberTaskViewer.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class NumberTaskViewer : BaseTaskViewer, UITextFieldDelegate {
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var rangeHeight: NSLayoutConstraint!

    var taskData : NumberTask {
        get {
            return task as! NumberTask
        }
    }
    var numberResult : NumberResult {
        get {
            return task!.result as! NumberResult
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        numberField.delegate = self
        if !taskData.isUnlimited!.boolValue {
            rangeLabel.text = "Range: \(taskData.minString) to \(taskData.maxString)"
            rangeLabel.isHidden = false
            rangeHeight.constant = rangeLabel.sizeThatFits(rangeLabel.bounds.size).height
        } else {
            rangeLabel.isHidden = true
            rangeHeight.constant = 0
        }
        if taskData.isDecimal!.boolValue {
            numberField.keyboardType = .decimalPad
        } else {
            numberField.keyboardType = .numberPad
        }
        numberField.addDoneHideKeyboardButtons(title: "Done", target: self, completion: #selector(doneButtonAction))
        if isEditable {
            numberField.becomeFirstResponder()
        }
        rangeLabel.makeTitleStyle()
        numberField.setActiveStyle(isActive: isEditable)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }

    @objc func doneButtonAction() {
        self.save()
        parentController?.dismiss(animated: true, completion: nil)
    }

    override func validate() -> String? {
        guard let text = numberField.text, let value = Float(text) else {
            return "No number value entered"
        }
        if taskData.isUnlimited!.boolValue {
            return nil
        }
        if value < Float(truncating: taskData.min!) {
            return "Value less than minimum allowed"
        }
        if value > Float(truncating: taskData.max!) {
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
        numberField.text = numberResult.resultString()
    }

    override func restore() {
        setNumberValue()
    }
}
