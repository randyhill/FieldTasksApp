//
//  TextTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/28/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TaskEditor : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
    }

    func setTask(task : Task) {
        FTErrorMessage(error: "must override method")
    }
}

class TextTaskEditor : TaskEditor {
    @IBOutlet weak var limitedLabel: UILabel!
    @IBOutlet weak var limitedSwitch: UISwitch!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var maxField: UITextField!
    private var task : TextTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        limitedLabel.makeTitleStyle()
        maxLabel.makeTitleStyle()
        maxField.setActiveStyle(isActive: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let task = task {
            limitedSwitch.isOn = !task.isUnlimited
            maxLabel.isHidden = task.isUnlimited
            maxField.isHidden = task.isUnlimited
            maxField.text = "\(task.max)"
        }
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
        maxLabel.isHidden = !limitedSwitch.isOn
        maxField.isHidden = !limitedSwitch.isOn
    }
}
