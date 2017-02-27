//
//  TemplateEditorController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TemplateEditorController : UIViewController, TemplateTasksToolProtocol {
    var listController : TemplateEditorListController?
    var template : Template?
    @IBOutlet weak var toolbar: TemplateTasksToolBar!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.delegate = self

        if let template = template {
            self.title = template.name
        } else {
            self.title = "New Template"
            template = Template()
        }
        self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(doneAction))
        makeNavBarFlat()
        self.view.backgroundColor = UIColor.wetAsphalt()

        // Do any additional setup after loading the view, typically from a nib.
        titleLabel.makeTitleStyle()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? TemplateEditorListController
        listController?.parentTemplateEditorController = self
    }

    func addTool(tool: TemplateTasksTool) {
//        var newTask : Task?
//        switch tool {
//            case .Text
//                newTask = TextTask()
//            case .Number
//            case .Choices
//            case .Text
//        }
    }

    func cancelAction () {
        self.dismiss(animated: true) { 

        }
    }

    func doneAction () {
        self.dismiss(animated: true) { 

        }

    }
    
}
