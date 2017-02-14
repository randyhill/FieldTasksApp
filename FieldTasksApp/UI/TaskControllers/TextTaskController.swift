//
//  TextTaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TextTaskController : TaskController {
    @IBOutlet weak var textView: UITextView!

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
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.frame = (self.view.frame)
        textView.layer.borderWidth =  1.0
        textView.isEditable = isEditable
        textView.font = Globals.shared.mediumFont
        textView.backgroundColor = UIColor.clouds()
        configureTextView(container: self.view)
        self.view.addSubview(textView)
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
        if let taskDescription = task?.taskDescription as? TextTaskDescription {
            if textView.text.characters.count > 0 {
                if !taskDescription.isUnlimited && textView.text.characters.count > taskDescription.max {
                    return "Too many characters, max allowed is \(taskDescription.max)"
                }
                return nil
            } else {
                return "You must enter text, it's required"
            }
        }
        return nil;
    }
}