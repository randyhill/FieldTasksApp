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
//    func addTouch() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
//        self.addGestureRecognizer(tapGesture)
//    }
//
//    func tapped(gesture : UITapGestureRecognizer) {
//        print("tapped: \(gesture.location(in: self))")
//    }
}

class ChoicesTaskEditor : TaskTypeEditor, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var multipleLabel: UILabel!
    @IBOutlet weak var multipleSwitch: FUISwitch!
    @IBOutlet weak var choiceField: UITextField!
    @IBOutlet weak var addChoice: FUIButton!
    @IBOutlet weak var editTable: FUIButton!
    @IBOutlet weak var tableView: UITableView!

    private var task : ChoicesTask?
    private var choices = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        multipleSwitch.makeFlatSwitch()
        multipleLabel.makeDetailStyle()
        choiceField.setActiveStyle(isActive: true)
        choiceField.addHideKeyboardButton()
        choiceField.delegate = self
        addChoice.makeFlatButton()
        editTable.makeFlatButton()
        tableView.backgroundColor = Globals.shared.bgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            multipleSwitch.isOn = !task.isRadio
            choices = task.titles
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        task?.isRadio = !multipleSwitch.isOn
        task?.titles = choices
    }

    override func setTask(task : Task) {
        self.task = task as? ChoicesTask
    }

    @IBAction func addChoice(_ sender: Any) {
        addChoiceString()
    }

    func addChoiceString() {
        if let text = choiceField.text, text.characters.count > 0 {
            choices += [text]
            choiceField.text = ""
            self.tableView.reloadData()
        }
    }

    @IBAction func toggleEditing(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editTable.setTitle(tableView.isEditing ? "Done" : "Edit List", for: .normal)
        editTable.setTitle(tableView.isEditing ? "Done" : "Edit List", for: .highlighted)
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            choices.remove(at: indexPath.row)
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
