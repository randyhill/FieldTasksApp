//
//  TabBarController.swift
//  FieldTasksApp
//
//  Created by CRH on 4/6/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Force login if session invalid
        if Globals.shared.tokenExpired {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginController")
            self.present(controller, animated: true, completion: {})
        }
    }
}
