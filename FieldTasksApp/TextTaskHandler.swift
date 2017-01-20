//
//  TextTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

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

    override init(controller : UIViewController,  container : UIView, task: FormTask) {
        super.init(controller : controller, container: container, task: task)
        textView.frame = container.frame
        textView.layer.borderWidth =  1.0
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
}
