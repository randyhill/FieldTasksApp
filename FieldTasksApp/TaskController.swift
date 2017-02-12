//
//  TaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/22/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

// MARK: Task Handlers -------------------------------------------------------------------------------
class TaskController : UIViewController {
    var task : FormTask?
    var isEditable = true
    var parentController : TasksController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = parentController!.view.backgroundColor

        // Adjust location of description field based on it's size
        if let textView = parentController?.taskDescription, let label = parentController?.descriptionLabel {
            if task?.description.characters.count == 0 {
                // No Description, hide title/field
                label.isHidden = true
                textView.isHidden = true
                textView.frame.origin.x = 0
                textView.frame.size.height = 10
            } else {
                parentController?.descriptionLabel.isHidden = false
                textView.isHidden = false

                let contentSize = textView.sizeThatFits(textView.bounds.size)
                var frame = textView.frame
                frame.size.height = contentSize.height
                textView.frame = frame
            }
            let aspectRatioTextViewConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: textView, attribute: .width, multiplier: textView.bounds.height/textView.bounds.width, constant: 1)
            textView.addConstraint(aspectRatioTextViewConstraint)
        }
    }

    // Calculate offset where top field should start beased on whether
    // description field is visible or not
    func firstFieldOrigin() -> CGFloat {
        if task?.description.characters.count == 0 {
            return parentController!.descriptionLabel.frame.origin.x
        } else {
            let descriptionFrame = parentController!.taskDescription.frame
            return descriptionFrame.origin.x + descriptionFrame.size.height + 10
        }
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
