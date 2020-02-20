//
//  LoginController.swift
//  FieldTasksApp
//
//  Created by CRH on 4/6/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import UIKit
import AVFoundation
import FlatUIKit

class LoginController : UIViewController {

    @IBOutlet weak var tenantField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: FUIButton!
    @IBOutlet weak var registerButton: FUIButton!

    // MARK: View Methods  -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.setActiveStyle(isActive: true)
        passwordField.setActiveStyle(isActive: true)
        loginButton.makeFlatButton()
        registerButton.makeFlatButton()

        NotificationCenter.default.addObserver(self, selector: #selector(appActivated), name: NSNotification.Name(rawValue: cAppActivated), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let bottomLayer = self.view.layer.sublayers?.first {
            self.view.layer.insertSublayer(self.playerLayer, below: bottomLayer)
        }
        tenantField.text = Globals.shared.tenantName
        emailField.text = Globals.shared.loginEmail
        if tenantField.text!.count == 0 {
            tenantField.becomeFirstResponder()
        } else if emailField.text!.count == 0 {
            emailField.becomeFirstResponder()
        } else {
            passwordField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    // If orientation changes
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        playerLayer.frame = self.view.frame
    }

    // MARK: Actions  -------------------------------------------------------------------------------
    @IBAction func registerAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {

        })
    }

    @IBAction func loginAction(_ sender: Any) {
        let email = emailField.text!
        let tenant = tenantField.text!
        Globals.shared.tenantName = tenant
        Globals.shared.loginEmail = email
        CoreDataMgr.shared.saveOnMainThread()
        ServerMgr.shared.login(tenant: tenant, accountEmail: email, password: passwordField.text!) { (tokenDict, error) in
            if let tokenDict = tokenDict {
                // Server will clean up tenant names so they can be used in paths, removing spaces/bad chars, make sure we store and use
                let token = tokenDict["token"] as? String
                let tenantName = tokenDict["tenant"] as? String
                let expiration = (tokenDict["expiration"] as? Int64) ?? 0
                Globals.shared.setToken(token: token ?? "", expiration: expiration, email: email, tenant: tenantName ?? tenant)
                self.dismiss(animated: true, completion: {

                })
            } else {
                FTAlertError(message: error ?? "Could not login due to unknown error")
            }
        }
    }

    @objc func appActivated() {
        self.playerLayer.player?.play()
    }

    // MARK: Animation  -------------------------------------------------------------------------------
    @objc func playerDidReachEnd(){
        self.playerLayer.player!.seek(to: CMTime.zero)
        self.playerLayer.player!.play()

    }

    lazy var playerLayer:AVPlayerLayer = {

        let player = AVPlayer(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "LaunchMovie", ofType: "mp4")!) as URL)
        player.isMuted = true
        player.allowsExternalPlayback = false
        player.appliesMediaSelectionCriteriaAutomatically = false
        var error:NSError?

        // This is needed so it would not cut off users audio (if listening to music etc.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch var error1 as NSError {
            error = error1
        } catch {
            fatalError()
        }
        if error != nil {
            print(error ?? "Unknown error initiatalizing player")
        }

        var playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: "AVLayerVideoGravityResizeAspectFill")
        playerLayer.backgroundColor = UIColor.black.cgColor
        player.play()
        NotificationCenter.default.addObserver(self, selector:#selector(LoginController.playerDidReachEnd), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:nil)
        return playerLayer
    }()
}
