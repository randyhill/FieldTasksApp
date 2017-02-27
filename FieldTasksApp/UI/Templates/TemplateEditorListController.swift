//
//  TemplateEditorListController.swift
//  FieldTasksApp
//
//  Created by CRH on 2/26/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TemplateEditorListController : UITableViewController {
    var parentTemplateEditorController : TemplateEditorController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adjustment because we are now in container view
       // self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0)

        tableView.backgroundColor = UIColor.greenSea()
    }
}
