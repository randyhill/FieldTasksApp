//
//  UIButton.swift
//  FieldTasksApp
//
//  Created by CRH on 2/15/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import FlatUIKit

extension FUIButton {
    func makeFlatButton() {
        self.buttonColor = Globals.shared.barButtonColor
        self.shadowColor = UIColor.wetAsphalt()
        self.shadowHeight = 2.0
        self.cornerRadius = 6.0
        self.titleLabel?.font = UIFont.boldFlatFont(ofSize: 16)
        self.setTitleColor(UIColor.clouds(), for: .normal)
        self.setTitleColor(UIColor.clouds(), for: .highlighted)
    }
    func makeFlatBarButton(target: Any?, action: Selector) -> UIBarButtonItem  {
        self.makeFlatButton()
        self.frame = CGRect(x: 0, y: 0, width: 53, height: 31)
        self.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: self)
    }
}
