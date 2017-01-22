//
//  TaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit



class TaskController : UIViewController {
    var form : Template?
    var isEditable = true
    var taskIndex = 0
    var viewLayoutInited = false
    var taskHandler : TaskHandler?
    var curTask : FormTask {
        get {
            return form!.tasks[taskIndex]
        }
    }
    @IBOutlet var taskDescription : UITextView!
    @IBOutlet var taskView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        setBackButton(title: "Back")
//        setNextButton(title: "Next")
    }

    func setBackButton(title: String) {
        let backButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevTask))
        navigationItem.leftBarButtonItem = backButton
    }

    func setNextButton(title: String) {
        let nextButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextTask))
        navigationItem.rightBarButtonItem = nextButton
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
         if curTask.name.characters.count > 0 {
            self.title = curTask.name
        } else {
            self.title = "Task"
        }
        self.taskDescription.text = curTask.description

        setBackButton(title: taskIndex == 0 ? "Done" : "Back")
        setNextButton(title: taskIndex == (form!.tasks.count - 1) ? "Done" : "Next")
    }

    func createNewTask() {
        let task = form!.tasks[taskIndex]

        // Swap out previous task UI and replace it with ours
        for view in taskView!.subviews {
            view.removeFromSuperview()
        }
        let subView = UIView()
        subView.frame = CGRect(x: 0, y: 0, width: taskView!.frame.width, height: taskView!.frame.height)
        taskView!.addSubview(subView)
        switch task.type {
        case "Text":
            taskHandler = TextTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        case "Number":
            taskHandler = NumberTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        case "Choices":
            taskHandler = ChoiceTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        case "Photo":
            taskHandler = PhotoTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        case "Worker":
            taskHandler = WorkerTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        case "Customer":
            taskHandler = CustomerTaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        default:
            taskHandler = TaskHandler(controller : self, container: subView, task: task, isEditable: isEditable)
        }
        taskHandler?.restore()
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
        if let errorMessage = taskHandler?.validate() {
            self.showAlert(title: "Invalid value", message: errorMessage)
//            let alert = UIAlertController(title: "Invalid value", message: errorMessage, preferredStyle: .Alert)
//            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) in
//
//            })
//            alert.addAction(ok)
//            self.presentViewController(alert, animated: true, completion: {
//
//            })
            return false
        }
        return true
    }
    @IBAction func prevTask(){
        if validateFields() {
            taskHandler!.save()
            taskIndex -= 1
            if taskIndex >= 0 {
                self.updateViewValues()
                self.createNewTask()
                setBackButton(title: taskIndex == 0 ? "Done" : "Back")
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func nextTask() {
        if validateFields() {
            taskHandler!.save()
            taskIndex += 1
            if taskIndex < form!.tasks.count {
                self.updateViewValues()
                self.createNewTask()
                setNextButton(title: taskIndex == (form!.tasks.count - 1) ? "Done" : "Next")
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}

