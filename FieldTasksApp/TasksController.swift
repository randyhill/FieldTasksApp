//
//  TaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit
import SVProgressHUD

class TasksController : UIViewController {
    var form : Template?
    var isEditable = true
    var taskIndex = 0
    var viewLayoutInited = false
    var taskController : TaskController?
    var curTask : FormTask {
        get {
            return form!.tasks[taskIndex]
        }
    }
    private var embeddedVC : TaskController?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var taskDescription : UITextView!
    @IBOutlet var taskView : UIView!
    @IBOutlet var doneButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavBarFlat()
        self.view.backgroundColor = Globals.shared.bgColor
        self.descriptionLabel.textColor = Globals.shared.textColor
        self.descriptionLabel.font = Globals.shared.bigFont
        self.taskDescription.textColor = Globals.shared.textColor
        self.taskDescription.font = Globals.shared.mediumFont
        self.taskView.backgroundColor = Globals.shared.bgColor

        doneButton.backgroundColor = Globals.shared.barButtonColor
        doneButton.setTitleColor(Globals.shared.textColor, for: .normal)
        doneButton.titleLabel!.font = Globals.shared.mediumFont
        doneButton.layer.cornerRadius = 4.0
        doneButton.isHidden = true


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateViewValues()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !viewLayoutInited {
            self.createNewTask()
            viewLayoutInited = true
        }
    }

    func updateViewValues() {
        var barTitle = ""
         if curTask.name.characters.count > 0 {
            barTitle = curTask.name
        } else {
            barTitle = "Task"
        }
        if curTask.required {
            barTitle += " (required)"
        }
        self.title = barTitle;
        self.taskDescription.text = curTask.description

        setBackButton(title: taskIndex == 0 ? "Done" : "Back")
        setNextButton(title: taskIndex == (form!.tasks.count - 1) ? "Done" : "Next")
    }

    func setBackButton(title: String) {
        let backButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevTask))
        navigationItem.leftBarButtonItem = backButton
    }

    func setNextButton(title: String) {
        let nextButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextTask))
        navigationItem.rightBarButtonItem = nextButton
    }
    

    func createNewTask() {
        let task = form!.tasks[taskIndex]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch task.type {
        case "Text":
             taskController = storyboard.instantiateViewController(withIdentifier: "TextTaskController") as? TaskController
        case "Number":
            taskController = storyboard.instantiateViewController(withIdentifier: "NumberTaskController") as? TaskController
        case "Choices":
            taskController = storyboard.instantiateViewController(withIdentifier: "ChoiceTaskController") as? TaskController
       case "Photo":
            taskController = storyboard.instantiateViewController(withIdentifier: "PhotoTaskController") as? TaskController
        default:
            taskController = storyboard.instantiateViewController(withIdentifier: "TextTaskController") as? TaskController
        }
        taskController?.task = task
        taskController?.parentController = self
        taskController?.isEditable = isEditable
        self.addChildViewController(taskController!)
        self.taskView.addSubview(taskController!.view)
        taskController?.restore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions -------------------------------------------------------------------------------
    func validateFields() -> Bool {
        if !curTask.required {
            return true
        }
        if let errorMessage = taskController?.validate() {
            SVProgressHUD.showError(withStatus: "Incomplete: \(errorMessage)")
            return false
        }
        return true
    }

    @IBAction func prevTask(){
        if validateFields() {
            taskController!.save()
            taskIndex -= 1
            if taskIndex >= 0 {
                self.updateViewValues()
                self.createNewTask()
                setBackButton(title: taskIndex == 0 ? "Done" : "Back")
                //doneButton.isHidden = taskIndex == 0
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func nextTask() {
        if validateFields() {
            taskController!.save()
            taskIndex += 1
            if taskIndex < form!.tasks.count {
                self.updateViewValues()
                self.createNewTask()
                setNextButton(title: taskIndex == (form!.tasks.count - 1) ? "Done" : "Next")
                //doneButton.isHidden = taskIndex == (form!.tasks.count - 1)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func done() {
        if validateFields() {
            taskController!.save()
            dismiss(animated: true, completion: nil)
        }
    }
}

