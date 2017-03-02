//
//  FUISwitch.swift
//  FieldTasksApp
//
//  Created by CRH on 3/1/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

let cSwitchSize = CGSize(width: 64.0, height: 44.0)

extension FUISwitch {
    func makeFlatSwitch() {
        self.frame.size.height = cSwitchSize.height
        self.frame.size.width = cSwitchSize.width
        self.onColor = UIColor.turquoise()
        self.offColor = UIColor.clouds()
        self.onBackgroundColor = UIColor.midnightBlue()
        self.offBackgroundColor = UIColor.asbestos()
        self.offLabel.font = UIFont.boldFlatFont(ofSize: 14)
        self.onLabel.font = UIFont.boldFlatFont(ofSize: 14)
        self.backgroundColor = UIColor.clear
    }
}
