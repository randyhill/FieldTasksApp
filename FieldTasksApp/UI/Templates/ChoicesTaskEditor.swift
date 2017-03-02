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

class ChoicesTaskEditor : TaskTypeEditor, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var multipleLabel: UILabel!
    @IBOutlet weak var multipleSwitch: FUISwitch!
    @IBOutlet weak var choiceField: UITextField!
    @IBOutlet weak var addChoice: FUIButton!
    @IBOutlet weak var tableView: UITableView!

    private var task : ChoicesTask?
    private var choices = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        multipleSwitch.makeFlatSwitch()
        multipleLabel.makeDetailStyle()
        choiceField.setActiveStyle(isActive: true)
        addChoice.makeFlatButton()
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
        if let text = choiceField.text, text.characters.count > 0 {
            choices += [text]
            self.tableView.reloadData()
        }
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            choices.remove(at: indexPath.row)
            self.tableView.reloadData()
        } else {
            print("unimplemented editing style")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChoicesTaskCell", for: indexPath) as? ChoicesTaskCell {
            cell.textLabel?.text = choices[indexPath.row]
            cell.makeCellFlat(backgroundColor: UIColor.midnightBlue(), selectedColor: UIColor.asbestos())
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
