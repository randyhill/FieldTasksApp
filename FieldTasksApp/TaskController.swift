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
    var taskHandler : TaskHandler?
    @IBOutlet var taskDescription : UITextView!
    @IBOutlet var taskView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateViewValues()
        self.createNewTask()
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(prevTask))
        navigationItem.leftBarButtonItem = backButton
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(nextTask))
        navigationItem.rightBarButtonItem = nextButton
    }

    func updateViewValues() {
        let task = form!.tasks[taskIndex]
        if task.name.characters.count > 0 {
            self.title = task.name
        } else {
            self.title = "Task"
        }
        self.taskDescription.text = task.description
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
            taskHandler = TextTaskHandler(container: subView)
        case "Number":
            taskHandler = NumberTaskHandler(container: subView)
        case "PhoneNumber":
            taskHandler = PhoneTaskHandler(container: subView)
        case "Choice":
            taskHandler = ChoiceTaskHandler(container: subView)
        case "Photo":
            taskHandler = PhotoTaskHandler(container: subView)
        case "Worker":
            taskHandler = WorkerTaskHandler(container: subView)
        case "Customer":
            taskHandler = CustomerTaskHandler(container: subView)
        default:
            taskHandler = TaskHandler(container: subView)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions -------------------------------------------------------------------------------
    @IBAction func prevTask(){
        taskIndex -= 1
        if taskIndex >= 0 {
            self.updateViewValues()
            self.createNewTask()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func nextTask() {
        taskIndex += 1
        if taskIndex < form!.tasks.count {
            self.updateViewValues()
            self.createNewTask()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: Task Handlers -------------------------------------------------------------------------------
class TaskHandler {
    init(container : UIView) {
        //container.backgroundColor = UIColor.blueColor()
    }
    func save() {

    }
}

class TextTaskHandler : TaskHandler {
    let textView = UITextView()

    override init(container : UIView) {
        super.init(container: container)
        textView.frame = container.frame
        textView.layer.borderWidth =  2.0
        container.addSubview(textView)
        textView.becomeFirstResponder()
    }
}

class NumberTaskHandler : TextTaskHandler {

}

class PhoneTaskHandler : NumberTaskHandler {

}

class ChoiceTaskHandler : TaskHandler {

}

class PhotoTaskHandler : TaskHandler {

}

class WorkerTaskHandler : TaskHandler {

}

class CustomerTaskHandler : TaskHandler {

}