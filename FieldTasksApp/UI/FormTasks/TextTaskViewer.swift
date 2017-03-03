//
//  TextTaskViewer.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TextTaskViewer : BaseTaskViewer {
    @IBOutlet weak var textView: UITextView!

    var textDescription : TextTask {
        get {
            return task as! TextTask
        }
    }
    var result : TextResult {
        get {
            return task!.result as! TextResult
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

         configureTextView(container: self.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }

    func configureTextView(container : UIView) {
        textView.setActiveStyle(isActive: isEditable)
        if isEditable {
            textView.addDoneHideKeyboardButtons(title: "Done", target: self, completion: #selector(self.doneButton))
//            textView.text = result.text
//            textView.selectedRange = NSMakeRange(textView.text.characters.count, 0)
//            textView.becomeFirstResponder()
      }
    }

    func doneButton() {
        self.save()
        parentController?.dismiss(animated: true, completion: nil)
    }

    override func save() {
        result.save(newText: textView.text)
        textView.resignFirstResponder()
    }
    override func restore() {
        textView.text = result.text
    }
    override func validate() -> String? {
        if let textTask = task as? TextTask {
            if textView.text.characters.count > 0 {
                if !textTask.isUnlimited && textView.text.characters.count > textTask.max {
                    return "Too many characters, max allowed is \(textTask.max)"
                }
                return nil
            } else {
                return "You must enter text, it's required"
            }
        }
        return nil;
    }
}
