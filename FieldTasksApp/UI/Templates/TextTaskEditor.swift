//
//  TextTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/28/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TextTaskEditor : TaskTypeEditor {
    @IBOutlet weak var limitedLabel: UILabel!
    @IBOutlet weak var limitedSwitch: FUISwitch!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var maxField: UITextField!
    private var task : TextTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        limitedLabel.makeDetailStyle()
        maxLabel.makeDetailStyle()
        maxField.setActiveStyle(isActive: true)
        maxField.addHideKeyboardButton()
        limitedSwitch.makeFlatSwitch()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            limitedSwitch.isOn = !task.isUnlimited
            maxField.text = "\(task.max)"
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        task?.isUnlimited = !limitedSwitch.isOn
        task?.max = Int(maxField.text!) ?? 0
    }

    override func setTask(task : Task) {
        self.task = task as? TextTask
    }

    @IBAction func limitChanged(_ sender: Any) {
       showHideFields()
    }

    override func showHideFields() {
        maxLabel.isHidden = !limitedSwitch.isOn
        maxField.isHidden = !limitedSwitch.isOn
        if limitedSwitch.isOn {
            maxField.text = ""
            maxField.becomeFirstResponder()
        }
    }
}
