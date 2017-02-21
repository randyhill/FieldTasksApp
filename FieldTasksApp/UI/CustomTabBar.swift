//
//  CustomTabBar.swift
//  FieldTasksApp
//
//  Created by CRH on 2/20/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class CustomTabBar : UITabBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       // self.backgroundColor = UIColor.peterRiver()
        self.barTintColor = UIColor.peterRiver()
        self.tintColor = UIColor.clouds()
    }
}
