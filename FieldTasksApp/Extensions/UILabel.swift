//
//  UILabel.swift
//  FieldTasksApp
//
//  Created by CRH on 2/8/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

extension UILabel {
    func makeTitleStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.boldFlatFont(ofSize: cTitleFontSize)
    }

    func makeDetailStyle() {
        self.textColor = UIColor.clouds()
        self.font = UIFont.flatFont(ofSize: cDetailFontSize)
    }

}
