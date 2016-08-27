//
//  TaskController.swift
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit



class TaskController : UIViewController {
    var form : Form?
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


        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(prevTask))
        navigationItem.leftBarButtonItem = backButton
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(nextTask))
        navigationItem.rightBarButtonItem = nextButton
    }

    override func viewWillAppear(animated: Bool) {
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
    }

    func createNewTask() {
        let task = form!.tasks[taskIndex]

        // Swap out previous task UI and replace it with ours
        for view in taskView!.subviews {
            view.removeFromSuperview()
        }
        let subView = UIView()
        subView.frame = CGRectMake(0, 0, taskView!.frame.width, taskView!.frame.height)
        taskView!.addSubview(subView)
        switch task.type {
        case "Text":
            taskHandler = TextTaskHandler(controller : self, container: subView, task: task)
        case "Number":
            taskHandler = NumberTaskHandler(controller : self, container: subView, task: task)
        case "Choices":
            taskHandler = ChoiceTaskHandler(controller : self, container: subView, task: task)
        case "Photo":
            taskHandler = PhotoTaskHandler(controller : self, container: subView, task: task)
        case "Worker":
            taskHandler = WorkerTaskHandler(controller : self, container: subView, task: task)
        case "Customer":
            taskHandler = CustomerTaskHandler(controller : self, container: subView, task: task)
        default:
            taskHandler = TaskHandler(controller : self, container: subView, task: task)
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
            self.showAlert("Invalid value", message: errorMessage)
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
            } else {
                dismissViewControllerAnimated(true, completion: nil)
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
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

