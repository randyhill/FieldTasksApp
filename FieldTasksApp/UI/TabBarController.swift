//
//  TabBarController.swift
//  FieldTasksApp
//
//  Created by CRH on 4/6/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Should always be installed since tab bar never goes away?
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOut), name: NSNotification.Name(rawValue: cAppLoggedOut), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Force login if session invalid
        if Globals.shared.tokenExpired {
            self.displayLogoutScreen()
        }
    }

    @objc func loggedOut() {
        self.displayLogoutScreen()
    }

    func displayLogoutScreen() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginController")
        self.present(controller, animated: true, completion: {})
    }
}
