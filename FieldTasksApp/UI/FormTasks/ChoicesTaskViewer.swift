//
//  ChoicesTaskViewer.swift
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
    var delegate : ChoicesAction?
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

    @objc func labelTap(tap : UIGestureRecognizer) {
        self.toggle()
        delegate?.choiceToggled(choice: self)
    }

    init(frame : CGRect, width: CGFloat, title: String, delegate: ChoicesAction) {
        // Make label for title
        self.delegate = delegate
        var labelFrame = frame
        labelFrame.origin.x = width + 24.0
        switchSize.width = width
        label.frame = labelFrame
        label.frame.size.width = title.widthOfString(usingFont: label.font) + 20
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTap))
        label.addGestureRecognizer(tapGesture)
        label.text = title;
        label.makeTitleStyle()
    }

    func setIndex(listIndex : Int) {
        self.listIndex = listIndex
        label.tag = listIndex
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
    init(frame : CGRect, title : String, isEnabled: Bool, delegate: ChoicesAction) {
        super.init(frame : frame, width: 64.0, title: title, delegate: delegate)
        _switch.frame = frame
        _switch.frame.size.width = switchSize.width;
        _switch.addTarget(self, action: #selector(didSwitch), for: .valueChanged)
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

    @objc func didSwitch(sender: UISwitch) {
        delegate?.choiceToggled(choice: self)
    }
}


// MARK: Checkbox Class -------------------------------------------------------------------------------
class Checkbox : Switchbox {
    private var _on = false
    //private var button = UIButton()
//    override var on : Bool {
//        get {
//            return _on
//        }
//        set(newOn) {
//            _on = newOn
//            if newOn {
//                button.setTitle("X", for: .normal)
//            } else {
//                button.setTitle("", for: .normal)
//            }
//        }
//    }

//    init(frame : CGRect, handler: ChoicesTaskViewer, title : String, isEnabled: Bool) {
//        super.init(frame : frame, width: 34.0, handler: handler, title: title)
//        button.frame = frame
//        button.frame.size.width = frame.height
//        button.layer.borderWidth = 2.0
//        button.setTitleColor(UIColor.black, for: .normal)
//        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18.0)
//        button.addTarget(handler, action: #selector(ChoicesTaskViewer.didCheck), for: .touchUpInside)
//        button.isEnabled = isEnabled
//        button.backgroundColor = UIColor.silver()
//        view = button
//    }

    override func setIndex(listIndex : Int) {
        super.setIndex(listIndex: listIndex)
//        button.tag = listIndex
    }
}

protocol ChoicesAction {
    func choiceToggled(choice : Choice)
}

// MARK: ChoicesTaskViewer Class -------------------------------------------------------------------------------
class ChoicesTaskViewer : BaseTaskViewer, ChoicesAction {
    var options = [Choice]()
    var otherField = UITextField()
    var choiceData : ChoicesTask {
        get {
            return task as! ChoicesTask
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
        if let task = task as? ChoicesTask {
            var choiceFrame = CGRect(x: 8, y: 8, width: (self.view.frame.width), height: 28)
            let isRadio = task.isRadio
            for title in choiceData.titles! {
                let choice = makeSwitchbox(container: self.view, title: title, frame: choiceFrame, isRadio: isRadio!.boolValue)
                choiceFrame.origin.y += choice.switchSize.height;
            }
            // Add Other: text field
            let choice = makeSwitchbox(container: self.view, title: "Other: ", frame: choiceFrame, isRadio: isRadio!.boolValue)
            let labelOffset = choice.label.frame.origin.x + choice.label.frame.width + 4
            choiceFrame.origin.x = labelOffset
            choiceFrame.size.width = self.view.frame.width - labelOffset - 20
            otherField.frame = choiceFrame
            otherField.isHidden = true
            otherField.setActiveStyle(isActive: self.isEditable)
            otherField.addHideKeyboardButton()
            self.view.addSubview(otherField)
        }
    }

    func toggleOther(otherSwitch : FUISwitch) {
        otherField.isHidden = !otherSwitch.isOn
    }

    func choiceToggled(choice: Choice) {
        selectBoxView(selectedOption: choice.view!)
        if choice.label.tag == options.count - 1 {
            otherField.isHidden = !choice.on
        }
    }

    func makeSwitchbox(container: UIView, title: String, frame : CGRect, isRadio: Bool) -> Choice {
        // Make switch control
        var choice : Choice?
        if isRadio {
            choice = Switchbox(frame: frame, title: title, isEnabled: isEditable, delegate: self)
        } else {
            choice = Checkbox(frame: frame, title: title, isEnabled: isEditable, delegate: self)
        }
        options += [choice!]
        self.view.addSubview(choice!.view!)
        self.view.addSubview(choice!.label)
        choice!.setIndex(listIndex: options.count - 1)
        return choice!
    }

    func didCheck(button: UIButton) {
        let choice = options[button.tag]
        choice.toggle()
        selectBoxView(selectedOption: button)
    }

    func selectBoxView(selectedOption : UIView) {
        if choiceData.isRadio!.boolValue {
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
         if choiceData.isRadio!.boolValue && options.count > 1 {
            return "You must select one option"
        } else {
            return nil
        }
    }

    override func save() {
        if let task = task as? ChoicesTask {
            var selections = [String]()
            for i in 0..<options.count {
                if options[i].on {
                    if i == options.count - 1 {
                        selections += [otherField.text!]
                    } else {
                        selections += [task.titles![i]]
                    }
                }
            }
            result.save(newValues: selections)
        }
    }

    override func restore() {
        if let task = task as? ChoicesTask {
            // Use array of selected values to traverse titles, checking matches and removing value to mark it found.
            var values = result.values.map{ $0 }!
            for i in 0..<task.titles!.count {
                let title = task.titles![i]
                for j in 0..<values.count {
                    let value = values[j]
                     if value == title {
                        options[i].on = true
                        values.remove(at: j)
                        break
                    }
                }
            }
            // If any value is left it must be the Other option.
            if values.count > 0 {
                options[options.count - 1].on = true
                otherField.isHidden = false
                otherField.text = values.last!
            }
        }

    }
}
