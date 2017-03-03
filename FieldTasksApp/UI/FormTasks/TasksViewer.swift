//
//  TasksViewer
//  FieldTasksApp
//
//  Created by CRH on 8/20/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TasksViewer : UIViewController {
    var form : Template?
    var isEditable = true
    var taskIndex = 0
    var viewLayoutInited = false
    var taskController : BaseTaskViewer?
    var curTask : Task {
        get {
            return form!.tasks[taskIndex]
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet var taskDescription : UITextView!
    @IBOutlet var taskView : UIView!
    @IBOutlet var doneButton : FUIButton!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var requiredConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavBarFlat()
        self.view.backgroundColor = Globals.shared.bgColor
        self.descriptionLabel.makeTitleStyle()
        self.taskDescription.makeDetailStyle()
        self.requiredLabel.makeTitleStyle()
        self.taskView.backgroundColor = Globals.shared.bgColor
        doneButton.makeFlatButton()
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

        self.title = barTitle;
        self.requiredLabel.isHidden = !curTask.required
        taskDescription.text = curTask.description

        setBackButton(index: taskIndex)
        setNextButton(index: taskIndex)
    }

    func setBackButton(index: Int) {
        if index == 0 {
            navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(prevTask))
        } else {
            navigationItem.leftBarButtonItem = FlatBarButton(withImageNamed: "leftarrow", target: self, action: #selector(prevTask))
        }
    }

    func setNextButton(index: Int) {
        if index == (form!.tasks.count - 1) {
            navigationItem.rightBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(nextTask))
        } else {
            navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "rightarrow", target: self, action: #selector(nextTask))
        }
    }

    func createNewTask() {
        let task = form!.tasks[taskIndex]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        taskController = storyboard.instantiateViewController(withIdentifier: task.viewerId) as? BaseTaskViewer
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
//    func validateFields() -> Bool {
//        if !curTask.required {
//            return true
//        }
//        if let errorMessage = taskController?.validate() {
//            SVProgressHUD.showError(withStatus: "Invalid: \(errorMessage)")
//            return false
//        }
//        return true
//    }

    @IBAction func prevTask(){
        taskController!.save()
        taskIndex -= 1
        if taskIndex >= 0 {
            self.updateViewValues()
            self.createNewTask()
            setBackButton(index: taskIndex)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func nextTask() {
        taskController!.save()
        taskIndex += 1
        if taskIndex < form!.tasks.count {
            self.updateViewValues()
            self.createNewTask()
            setNextButton(index: taskIndex)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func done() {
        taskController!.save()
        dismiss(animated: true, completion: nil)
    }
}

