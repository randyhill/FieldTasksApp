//
//  FormsController.swift
//  FieldTasksApp
//
//  Created by CRH on 1/18/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class FormsController : UIViewController {
    var listController : FormsListController?
    @IBOutlet weak var newButton: FUIButton!
    @IBOutlet weak var newTitle: UILabel!
    var location : FTLocation?    // Filter by location if set

    override func viewDidLoad() {
        super.viewDidLoad()

        newButton.makeFlatImageButton(imageNamed: "plus.png")
        newTitle.makeTitleStyle()
        self.view.backgroundColor = UIColor.wetAsphalt()

        if let location = location {
            self.title = location.name
        } else {
            self.title = "Forms"
        }
        self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshList))
        if location != nil {
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(goBack))
        }

        self.makeNavBarFlat()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? FormsListController
        listController?.parentFormsController = self
    }

    func goBack() {
        self.dismiss(animated: true) {
        }
    }

    func refreshList() {
        listController?.refreshList()
    }

    @IBAction func openPicker(_ sender: Any) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "TemplatesController") as? TemplatesController {
            formController.location = location
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}


