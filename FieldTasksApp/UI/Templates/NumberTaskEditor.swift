//
//  NumberTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 3/1/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class NumberTaskEditor : TaskTypeEditor {
    @IBOutlet weak var limitedLabel: UILabel!
    @IBOutlet weak var limitedSwitch: FUISwitch!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var decimalSwitch: FUISwitch!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var maxField: UITextField!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var minField: UITextField!
    
    private var task : NumberTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        limitedLabel.makeDetailStyle()
        limitedSwitch.makeFlatSwitch()
        decimalLabel.makeDetailStyle()
        decimalSwitch.makeFlatSwitch()
        maxLabel.makeDetailStyle()
        maxField.setActiveStyle(isActive: true)
        maxField.addHideKeyboardButton()
        minLabel.makeDetailStyle()
        minField.setActiveStyle(isActive: true)
        minField.addHideKeyboardButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            limitedSwitch.isOn = !(task.isUnlimited!.boolValue)
            decimalSwitch.isOn = task.isDecimal!.boolValue
            minField.text = task.minString
            maxField.text = task.maxString
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        task?.isUnlimited = !limitedSwitch.isOn as NSNumber?
        task?.isDecimal = decimalSwitch.isOn as NSNumber?
        task?.min = (Double(minField.text!) ?? 0) as NSNumber?
        task?.max = (Double(maxField.text!) ?? 0) as NSNumber?
    }

    override func setTask(task : Task) {
        self.task = task as? NumberTask
    }

    @IBAction func limitChanged(_ sender: Any) {
        showHideFields()
        if limitedSwitch.isOn {
            minField.text = ""
            maxField.text = ""
            minField.becomeFirstResponder()
        }
    }

    override func showHideFields() {
        maxLabel.isHidden = !limitedSwitch.isOn
        maxField.isHidden = !limitedSwitch.isOn
        minLabel.isHidden = !limitedSwitch.isOn
        minField.isHidden = !limitedSwitch.isOn
    }

    override func validate() -> String? {
        if limitedSwitch.isOn {
            let min = Double(minField.text!) ?? 0
            let max = Double(maxField.text!) ?? 0
            if min >= max {
                return "Minimum value must be less than maximum value"
            }
        }
        return nil
    }
}
