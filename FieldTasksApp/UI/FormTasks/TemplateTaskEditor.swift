//
//  TemplateTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 2/28/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TemplateTaskEditor : UIViewController {
     @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var embeddedView: UIView!

    var task : Task?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
        self.title = task?.type.rawValue ?? "Task"

        nameLabel.makeTitleStyle()
        nameField.setActiveStyle(isActive: true)
        nameField.text = task?.name ?? ""
        descriptionLabel.makeTitleStyle()
        descriptionField.makeFlatTextView()
        descriptionField.text = task?.description ?? ""

        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(doneAction))
        makeNavBarFlat()
    }

    func cancelAction () {
        self.dismiss(animated: true) {}
    }

    func doneAction () {
        self.task?.name = self.nameField.text!
        self.task?.description = self.descriptionField.text

        self.dismiss(animated: true) {}
    }
}