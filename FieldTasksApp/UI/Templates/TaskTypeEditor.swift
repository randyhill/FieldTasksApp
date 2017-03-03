//
//  TaskTypeEditor
//  FieldTasksApp
//
//  Created by CRH on 3/1/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TaskTypeEditor : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Globals.shared.bgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showHideFields()
    }

    func setTask(task : Task) {
        FTErrorMessage(error: "must override method")
    }

    func showHideFields() {
    }

    func validate() -> String? {
        return nil
    }
}
