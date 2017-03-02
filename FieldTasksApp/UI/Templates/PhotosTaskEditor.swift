//
//  PhotosTaskEditor.swift
//  FieldTasksApp
//
//  Created by CRH on 3/1/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

class PhotosTaskEditor : TaskTypeEditor {
    @IBOutlet weak var multipleLabel: UILabel!
    @IBOutlet weak var multipleSwitch: FUISwitch!

    private var task : PhotosTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        multipleSwitch.makeFlatSwitch()
        multipleLabel.makeDetailStyle()

    }

    override func viewWillAppear(_ animated: Bool) {
        if let task = task {
            multipleSwitch.isOn = !task.isSingle
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        task?.isSingle = !multipleSwitch.isOn
    }

    override func setTask(task : Task) {
        self.task = task as? PhotosTask
    }
}
