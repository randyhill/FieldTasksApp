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
        if let email = Globals.shared.userAccount {
            emailField.text = email
            passwordField.becomeFirstResponder()
        } else {
            emailField.becomeFirstResponder()
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

    @IBAction func loginAtion(_ sender: Any) {
        Globals.shared.userAccount = emailField.text
        ServerMgr.shared.login(clientName: "", accountEmail: emailField.text!, password: passwordField.text!) { (token, error) in
            if let token = token {
                Globals.shared.accessToken = token
                self.dismiss(animated: true, completion: { 

                })
            } else {
                FTAlertError(message: error ?? "Could not login do to unknown error")
            }
        }
    }

    func appActivated() {
        self.playerLayer.player?.play()
    }
    
    // MARK: Animation  -------------------------------------------------------------------------------
    func playerDidReachEnd(){
        self.playerLayer.player!.seek(to: kCMTimeZero)
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
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
        playerLayer.videoGravity = "AVLayerVideoGravityResizeAspectFill"
        playerLayer.backgroundColor = UIColor.black.cgColor
        player.play()
        NotificationCenter.default.addObserver(self, selector:#selector(LoginController.playerDidReachEnd), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:nil)
        return playerLayer
    }()
}
