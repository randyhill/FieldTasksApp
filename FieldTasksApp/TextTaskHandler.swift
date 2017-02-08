//
//  TextTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TextTaskHandler : TaskHandler {
    let textView = UITextView()
    var textDescription : TextTaskDescription {
        get {
            return task!.taskDescription as! TextTaskDescription
        }
    }
    var result : TextResult {
        get {
            return task!.result as! TextResult
        }
    }

    override init(controller : TaskController,  container : UIView, task: FormTask, isEditable: Bool) {
        super.init(controller : controller, container: container, task: task, isEditable: isEditable)
        textView.frame = container.frame
        textView.layer.borderWidth =  1.0
        textView.isEditable = isEditable
        textView.font = Globals.shared.mediumFont
        textView.backgroundColor = UIColor.clouds()
        configureTextView(container: container)
        container.addSubview(textView)
    }

    func configureTextView(container : UIView) {
        textView.becomeFirstResponder()
    }

    override func save() {
        result.save(newText: textView.text)
    }
    override func restore() {
        textView.text = result.text
    }
    override func validate() -> String? {
        if textView.text.characters.count > 0 {
            return nil
        } else {
            return "You must enter text, it's required"
        }
    }
}
