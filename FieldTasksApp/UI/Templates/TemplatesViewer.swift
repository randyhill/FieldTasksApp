//
//  TemplatesViewer
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

enum TemplatesViewerStyle {
    case List, Location, Picker
}

class TemplatesViewer : UIViewController {
    var location : FTLocation?
    var listController : TemplatesTable?
    var style = TemplatesViewerStyle.List
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var newButton: FUIButton!
    @IBOutlet weak var editButton: FUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Standard UI
        newButton.makeFlatButton()
        editButton.makeFlatButton()
        makeNavBarFlat()
        tasksLabel.makeDetailStyle()
        templateLabel.makeDetailStyle()
        self.view.backgroundColor = UIColor.wetAsphalt()

        switch style {
        case .List:
            self.title = "Templates"
            self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshList))
        case .Location:
            self.title = "Templates"
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(cancelAction))
            newButton.setTitle("Add", for: .normal)
            newButton.setTitle("Add", for: .highlighted)
        case .Picker:
            self.title = "Add Templates"
            self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Cancel", target: self, action: #selector(cancelAction))
            self.navigationItem.rightBarButtonItem = FlatBarButton(title: "Add", target: self, action: #selector(addAction))
            newButton.isHidden = true
            editButton.isHidden = true
            newButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10.0).isActive = true
            editButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10.0).isActive = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let style = sender as? TemplatesViewerStyle {
            if let navController = segue.destination as? UINavigationController {
                if let templateEditor = navController.topViewController as? TemplatesViewer {
                    templateEditor.style = style
                    templateEditor.location = self.location
                }
            }
        } else {
            listController = segue.destination as? TemplatesTable
            listController?.parentTemplatesViewer = self
        }
    }

    @IBAction func toggleEdit(_ sender: Any) {
        listController?.toggleEdit(button: editButton)
    }

    // Button is either New Template or Add Template, depending upon our style
    @IBAction func newAddAction(_ sender: Any) {
        switch style {
        case .List:
            // Create new
            self.performSegue(withIdentifier: "OpenTemplateEditor", sender: TemplatesViewerStyle.List)
        case .Location:
            self.performSegue(withIdentifier: "OpenTemplatesViewer", sender: TemplatesViewerStyle.Picker)
        case .Picker:
            break
        }
    }

    func addAction() {
        if let location = location {
            if let selectedTemplates = listController?.selectedTemplates() {
                location.addTemplates(newTemplates: selectedTemplates)
                ServerMgr.updateLocation(location: location, completion: { (error) in
                    FTAssertString(error: error)
                })
             }
        }
        self.dismiss(animated: true) {}
    }

    func cancelAction() {
        self.dismiss(animated: true) {}
    }

    func refreshList() {
        listController?.serverRefresh()
    }
}

