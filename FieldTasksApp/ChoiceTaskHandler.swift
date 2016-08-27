//
//  ChoiceTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

class ChoiceTaskHandler : TaskHandler {
    var options = [UISwitch]()
    var choiceData : ChoicesTaskDescription {
        get {
            return task!.taskDescription as! ChoicesTaskDescription
        }
    }
    var result : ChoicesResult {
        get {
            return task!.result as! ChoicesResult
        }
    }
    let kSwitchSize = CGSize(width: 48.0, height: 44.0)


    override init(controller : UIViewController, container : UIView, task: FormTask) {
        super.init(controller : controller,  container: container, task: task)

        var choiceFrame = CGRectMake(0, 0, container.frame.width, 28)
        for title in choiceData.titles {
            makeSwitch(container, title: title, frame: choiceFrame)
            choiceFrame.origin.y += kSwitchSize.height;
        }
    }

    func makeSwitch(container: UIView, title: String, frame : CGRect) {
        // Make switch control
        var choiceFrame = frame;
        choiceFrame.size.width = kSwitchSize.width;
        let choiceSwitch = UISwitch(frame: choiceFrame)
        choiceSwitch.addTarget(self, action: #selector(ChoiceTaskHandler.didSwitch), forControlEvents: .ValueChanged)
        options += [choiceSwitch]
        container.addSubview(choiceSwitch)

        // Make label for title
        var labelFrame = frame
        labelFrame.origin.x = kSwitchSize.width + 10.0
        let label = UILabel(frame: labelFrame)
        label.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChoiceTaskHandler.labelTap))
        label.addGestureRecognizer(tapGesture)
        label.text = title;
        label.tag = options.count - 1 // Label linked to option by it's array index
        container.addSubview(label)
    }

    func labelTap(tap : UIGestureRecognizer) {
        if let label = tap.view as? UILabel {
            let option = options[label.tag]
            option.on = !option.on
        }

    }

    func didSwitch(sender: UISwitch) {
        if choiceData.isRadio {
            for option in options {
                if (option != sender) {
                    option.on = false
                }
            }
        }
    }

    // Return nil if data user entered is valid or error message if not
    override func validate() -> String? {
        for option in options {
            if (option.on) {
                return nil;
            }
        }
        if choiceData.isRadio && options.count > 1 {
            return "You must select one option"
        } else {
            return nil
        }
    }
    override func save() {
        let boolValues = options.map{(control)->Bool in
            return control.on
        }
        result.save(boolValues)
//        result.values.removeAll()
//        for option in options {
//            result.values += [option.on]
//        }
//        if task!.required {
//            result.completed = result.values.count > 0
//        } else {
//            result.completed = true
//        }
    }
    override func restore() {
        for i in 0 ..< result.values.count {
            options[i].on = result.values[i]
        }
    }
}