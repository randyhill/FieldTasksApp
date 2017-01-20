//
//  ChoiceTaskHandler.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit

let kSwitchSize = CGSize(width: 48.0, height: 44.0)

// MARK: Choice Class -------------------------------------------------------------------------------
class Choice {
    var view : UIView?      // Active control, switch or checkbox
    var label = UILabel()   // Title for control
    var listIndex = 0
    var on : Bool {
        get {
            return false
        }
        set(newOn) {

        }
    }

    func toggle() {
        self.on = !self.on
    }

    init(frame : CGRect, handler: ChoiceTaskHandler, title: String) {
        // Make label for title
        var labelFrame = frame
        labelFrame.origin.x = kSwitchSize.width + 10.0
        label.frame = labelFrame
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: handler, action: #selector(ChoiceTaskHandler.labelTap))
        label.addGestureRecognizer(tapGesture)
        label.text = title;
    }

    func setIndex(listIndex : Int) {
        self.listIndex = listIndex
        label.tag = listIndex
    }
}

// MARK: Checkbox Class -------------------------------------------------------------------------------
class Checkbox : Choice {
    private var _on = false
    private var button = UIButton()
    override var on : Bool {
        get {
            return _on
        }
        set(newOn) {
            _on = newOn
            if newOn {
                button.setTitle("X", for: .normal)
            } else {
                button.setTitle("", for: .normal)
            }
        }
    }

    override init(frame : CGRect, handler: ChoiceTaskHandler, title : String) {
        super.init(frame : frame, handler: handler, title: title)
        button.frame = frame
        button.frame.size.width = frame.height
        button.layer.borderWidth = 2.0
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(handler, action: #selector(ChoiceTaskHandler.didCheck), for: .touchUpInside)
        view = button
     }

    override func setIndex(listIndex : Int) {
        super.setIndex(listIndex: listIndex)
        button.tag = listIndex
    }
}

// MARK: Switchbox Class -------------------------------------------------------------------------------
class Switchbox : Choice {
    private var _switch = UISwitch()
    override var on : Bool {
        get {
            return _switch.isOn
        }
        set(newOn) {
            _switch.isOn = newOn
        }
    }
    override init(frame : CGRect, handler: ChoiceTaskHandler, title : String) {
        super.init(frame : frame, handler: handler, title: title)
        _switch.frame = frame
        _switch.frame.size.width = kSwitchSize.width;
        _switch.addTarget(handler, action: #selector(ChoiceTaskHandler.didSwitch), for: .valueChanged)
        view = _switch
    }
}

// MARK: ChoiceTaskHandler Class -------------------------------------------------------------------------------
class ChoiceTaskHandler : TaskHandler {
    var options = [Choice]()
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

    override init(controller : UIViewController, container : UIView, task: FormTask) {
        super.init(controller : controller,  container: container, task: task)

        var choiceFrame = CGRect(x: 0, y: 0, width: container.frame.width, height: 28)
        let isRadio = (task.taskDescription as! ChoicesTaskDescription).isRadio
        for title in choiceData.titles {
            makeSwitchbox(container: container, title: title, frame: choiceFrame, isRadio: isRadio)
            choiceFrame.origin.y += kSwitchSize.height;
        }
    }

    func makeSwitchbox(container: UIView, title: String, frame : CGRect, isRadio: Bool) {
        // Make switch control
        var choice : Choice?
        if isRadio {
            choice = Switchbox(frame: frame, handler: self, title: title)
        } else {
            choice = Checkbox(frame: frame, handler: self, title: title)
        }
        options += [choice!]
        container.addSubview(choice!.view!)
        container.addSubview(choice!.label)
        choice!.setIndex(listIndex: options.count - 1)
    }

    func labelTap(tap : UIGestureRecognizer) {
        if let label = tap.view as? UILabel {
            let option = options[label.tag]
            option.on = !option.on
            selectBoxView(selectedOption: option.view!)
        }

    }

    func didSwitch(sender: UISwitch) {
        selectBoxView(selectedOption: sender)
    }

    func didCheck(button: UIButton) {
        let choice = options[button.tag]
        choice.toggle()
        selectBoxView(selectedOption: button)
    }

    func selectBoxView(selectedOption : UIView) {
        if choiceData.isRadio {
            for option in options {
                if (option.view != selectedOption) {
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
        result.save(newValues: boolValues)
    }
    override func restore() {
        for i in 0 ..< result.values.count {
            options[i].on = result.values[i]
        }
    }
}
