//
//  ChoiceTaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/23/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

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
    var switchSize = CGSize(width: 64.0, height: 44.0)

    func toggle() {
        self.on = !self.on
    }

    init(frame : CGRect, width: CGFloat, handler: ChoiceTaskController, title: String) {
        // Make label for title
        var labelFrame = frame
        labelFrame.origin.x = width + 8.0
        switchSize.width = width
        label.frame = labelFrame
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: handler, action: #selector(ChoiceTaskController.labelTap))
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

    init(frame : CGRect, handler: ChoiceTaskController, title : String, isEnabled: Bool) {
        super.init(frame : frame, width: 34.0, handler: handler, title: title)
        button.frame = frame
        button.frame.size.width = frame.height
        button.layer.borderWidth = 2.0
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18.0)
        button.addTarget(handler, action: #selector(ChoiceTaskController.didCheck), for: .touchUpInside)
        button.isEnabled = isEnabled
        button.backgroundColor = UIColor.silver()
        view = button
     }

    override func setIndex(listIndex : Int) {
        super.setIndex(listIndex: listIndex)
        button.tag = listIndex
    }
}

// MARK: Switchbox Class -------------------------------------------------------------------------------
class Switchbox : Choice {
    private var _switch = FUISwitch()
    override var on : Bool {
        get {
            return _switch.isOn
        }
        set(newOn) {
            _switch.isOn = newOn
        }
    }
    init(frame : CGRect, handler: ChoiceTaskController, title : String, isEnabled: Bool) {
        super.init(frame : frame, width: 64.0, handler: handler, title: title)
        _switch.frame = frame
        _switch.frame.size.width = switchSize.width;
        _switch.addTarget(handler, action: #selector(ChoiceTaskController.didSwitch), for: .valueChanged)
        _switch.isEnabled = isEnabled
        view = _switch
        _switch.onColor = UIColor.turquoise()
        _switch.offColor = UIColor.clouds()
        _switch.onBackgroundColor = UIColor.midnightBlue()
        _switch.offBackgroundColor = UIColor.asbestos()
        _switch.offLabel.font = UIFont.boldFlatFont(ofSize: 14)
        _switch.onLabel.font = UIFont.boldFlatFont(ofSize: 14)
        _switch.isOn = false
    }
}

// MARK: ChoiceTaskController Class -------------------------------------------------------------------------------
class ChoiceTaskController : TaskController {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        createChoices()
    }

    func createChoices() {
        var choiceFrame = CGRect(x: 8, y: 8, width: (self.view.frame.width), height: 28)
        let isRadio = (task?.taskDescription as! ChoicesTaskDescription).isRadio
        for title in choiceData.titles {
            let choice = makeSwitchbox(container: self.view, title: title, frame: choiceFrame, isRadio: isRadio)
            choiceFrame.origin.y += choice.switchSize.height;
        }
    }

    func makeSwitchbox(container: UIView, title: String, frame : CGRect, isRadio: Bool) -> Choice {
        // Make switch control
        var choice : Choice?
        if isRadio {
            choice = Switchbox(frame: frame, handler: self, title: title, isEnabled: isEditable)
        } else {
            choice = Checkbox(frame: frame, handler: self, title: title, isEnabled: isEditable)
        }
        options += [choice!]
        self.view.addSubview(choice!.view!)
        self.view.addSubview(choice!.label)
        choice!.setIndex(listIndex: options.count - 1)
        return choice!
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
        //createChoices()
        for i in 0 ..< result.values.count {
            options[i].on = result.values[i]
        }
    }
}
