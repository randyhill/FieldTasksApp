//
//  TaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/22/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

protocol TaskControllerProtocol {
    var task : Task? {get set}
    var isEditable : Bool {get set}
    var parentController : TasksController? {get set}

    func validate() -> String?
    func save()
    func restore()
}

func initParentTaskControllerArea(view: UIView, parentController: TasksController, task : Task) {
    view.backgroundColor = parentController.view.backgroundColor

    // Adjust location of description field based on it's size
    if let descriptionView = parentController.taskDescription, let label = parentController.descriptionLabel,
        let descriptionHeight = parentController.descriptionHeight, let descriptionTitle = parentController.descriptionTitleConstraint,
        let requiredConstraint = parentController.requiredConstraint, let requiredLabel = parentController.requiredLabel {
        if task.description.characters.count == 0 {
            // No Description, hide title/field
            label.isHidden = true
            descriptionView.isHidden = true
            descriptionHeight.constant = 0
            descriptionTitle.constant = 0
            if requiredLabel.isHidden {
                // Only hide the title area if the required text isn't
                requiredConstraint.constant = 0
             } else {
                requiredConstraint.constant = requiredLabel.sizeThatFits(requiredLabel.bounds.size).height
            }
        } else {
            parentController.descriptionLabel.isHidden = false
            descriptionView.isHidden = false

            let contentSize = descriptionView.sizeThatFits(descriptionView.bounds.size)
            descriptionHeight.constant = contentSize.height
            descriptionTitle.constant = label.sizeThatFits(label.bounds.size).height
            requiredConstraint.constant = requiredLabel.sizeThatFits(requiredLabel.bounds.size).height
        }
        view.layoutIfNeeded()
    }
}

// MARK: Task Handlers -------------------------------------------------------------------------------
class TaskController : UIViewController, TaskControllerProtocol {
    var task : Task?
    var isEditable = true
    var parentController : TasksController?

    override func viewDidLoad() {
        super.viewDidLoad()

        initParentTaskControllerArea(view: self.view, parentController: parentController!, task: task!)
    }

    // Return nil if data user entered is valid or error message if not
    func validate() -> String? {
        return nil
    }

    func save() {

    }

    func restore() {

    }
}
