//
//  ChoicesTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 3/1/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class ChoicesTaskCell : UITableViewCell {
}

class ChoicesTaskEditor : TaskTypeEditor, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var multipleLabel: UILabel!
    @IBOutlet weak var multipleSwitch: FUISwitch!
    @IBOutlet weak var choiceField: UITextField!
    @IBOutlet weak var addChoice: FUIButton!
    @IBOutlet weak var editTable: FUIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var otherSwitch: FUISwitch!
    @IBOutlet weak var otherTitle: UILabel!

    private var task : ChoicesTask?
    private var choices = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        multipleSwitch.makeFlatSwitch()
        multipleLabel.makeDetailStyle()
        otherSwitch.makeFlatSwitch()
        otherTitle.makeTitleStyle()
        choiceField.setActiveStyle(isActive: true)
        choiceField.addHideKeyboardButton()
        choiceField.delegate = self
        addChoice.makeFlatButton()
        editTable.makeFlatButton()
        tableView.backgroundColor = Globals.shared.bgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            multipleSwitch.isOn = task.isRadio!.boolValue
            otherSwitch.isOn = task.hasOther!.boolValue
            choices = task.titles!
        }
        super.viewWillAppear(animated)
        editTable.isHidden = (choices.count == 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        task?.isRadio = multipleSwitch.isOn as NSNumber?
        task?.titles = choices
        task?.hasOther = otherSwitch.isOn as NSNumber?
    }

    override func setTask(task : Task) {
        self.task = task as? ChoicesTask
    }

    @IBAction func addChoice(_ sender: Any) {
        addChoiceString()
    }

    func addChoiceString() {
        if let text = choiceField.text, text.count > 0 {
            choices += [text]
            choiceField.text = ""
            editTable.isHidden = (choices.count == 0)
            self.tableView.reloadData()
        }
    }

    @IBAction func toggleEditing(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editTable.setTitle(tableView.isEditing ? "Done" : "Edit", for: .normal)
        editTable.setTitle(tableView.isEditing ? "Done" : "Edit", for: .highlighted)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addChoiceString()
        return false
    }


    // MARK: Table Methods -------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            choices.remove(at: indexPath.row)
            editTable.isHidden = (choices.count == 0)
            if choices.count == 0 {
                self.toggleEditing(editTable as Any)
            }
            self.tableView.reloadData()
        } else {
            FTErrorMessage(error: "unimplemented editing style")
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedChoice = choices[sourceIndexPath.row]
        choices[sourceIndexPath.row] = choices[destinationIndexPath.row]
        choices[destinationIndexPath.row] = movedChoice
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChoicesTaskCell", for: indexPath) as? ChoicesTaskCell {
            cell.textLabel?.text = choices[indexPath.row]
            cell.detailTextLabel?.text = ""
            cell.makeCellFlat(backgroundColor: UIColor.midnightBlue(), selectedColor: UIColor.asbestos())
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
