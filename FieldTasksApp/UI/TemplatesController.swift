//
//  TemplatesController
//  FieldTasksApp
//
//  Created by CRH on 8/19/16.
//  Copyright © 2016 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class TemplatesController : UIViewController {
    var location : FTLocation?
    var listController : TemplatesListController?
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var templateLabel: UILabel!
    @IBOutlet weak var newButton: FUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Templates"
        self.navigationItem.rightBarButtonItem = FlatBarButton(withImageNamed: "refresh", target: self, action: #selector(refreshList))
        self.navigationItem.leftBarButtonItem = FlatBarButton(title: "Done", target: self, action: #selector(goBack))
        makeNavBarFlat()
        tasksLabel.makeDetailStyle()
        templateLabel.makeDetailStyle()
        newButton.makeFlatButton()
        self.view.backgroundColor = UIColor.wetAsphalt()
    }

    func goBack() {
        self.dismiss(animated: true) {

        }
    }

    func refreshList() {
        listController?.refreshList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        listController = segue.destination as? TemplatesListController
        listController?.parentTemplatesController = self
    }
}

