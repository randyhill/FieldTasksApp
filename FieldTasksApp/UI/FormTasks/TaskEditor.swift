//
//  TaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/28/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TaskEditor : UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var requiredSwitch: FUISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var embeddedView: UIView!
    var embeddedVC : UIViewController?
    var task : Task?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
        self.title = task?.type.rawValue ?? "Task"

        nameLabel.makeDetailStyle()
        nameField.setActiveStyle(isActive: true)

        requiredLabel.makeDetailStyle()
        requiredSwitch.makeFlatSwitch()

        descriptionLabel.makeDetailStyle()
        descriptionField.makeFlatTextView()

        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(doneAction))
        makeNavBarFlat()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let vc = self.storyboard?.instantiateViewController(withIdentifier: task!.editorId) as? TaskTypeEditor {
            vc.setTask(task: task!)
            vc.willMove(toParentViewController: self)
            self.embeddedView.addSubview(vc.view)
            self.addChildViewController(vc)
            vc.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            vc.didMove(toParentViewController: self)
            embeddedVC = vc
            vc.beginAppearanceTransition(true, animated: false)
        }

        nameField.text = task?.name ?? ""
        descriptionField.text = task?.description ?? ""
        requiredSwitch.isOn = task?.required ?? false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let vc = embeddedVC {
            vc.endAppearanceTransition()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let vc = embeddedVC {
            vc.beginAppearanceTransition(false, animated: false)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
         super.viewDidDisappear(animated)
        if let vc = embeddedVC {
            vc.endAppearanceTransition()
        }
    }

    func cancelAction () {
        self.dismiss(animated: true) {}
    }

    func doneAction () {
        self.task?.name = self.nameField.text!
        self.task?.description = self.descriptionField.text
        self.task?.required = self.requiredSwitch.isOn

        self.dismiss(animated: true) {}
    }
}
