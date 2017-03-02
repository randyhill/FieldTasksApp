//
//  FormsViewer.swift
//  FieldTasksApp
//
//  Created by CRH on 1/18/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class FormsViewer : UIViewController {
    var listController : FormsTable?
    @IBOutlet weak var newButton: FUIButton!
    @IBOutlet weak var formNameLabel: UILabel!
    @IBOutlet weak var formDateLabel: UILabel!
    var location : FTLocation?    // Filter by location if set

    override func viewDidLoad() {
        super.viewDidLoad()

        formDateLabel.makeDetailStyle()
        formNameLabel.makeDetailStyle()
        self.view.backgroundColor = UIColor.wetAsphalt()
        self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshList))

        if let location = location {
            self.title = location.name
            newButton.makeFlatImageButton(imageNamed: "plus.png")
            newButton.isHidden = false
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(goBack))
        } else {
            self.title = "Forms"
            newButton.isHidden = true
        }
        self.makeNavBarFlat()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? FormsTable
        listController?.parentFormsViewer = self
    }

    func goBack() {
        self.dismiss(animated: true) {
        }
    }

    func refreshList() {
        listController?.refreshList()
    }

    @IBAction func openPicker(_ sender: Any) {
        if let formController = self.storyboard?.instantiateViewController(withIdentifier: "TemplatesViewer") as? TemplatesViewer {
            formController.location = location
            let navController = UINavigationController(rootViewController: formController) // Creating a navigation controller with resultController at the root of the navigation stack.
            self.present(navController, animated: true, completion: {

            })
        }
    }
}


