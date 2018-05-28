//
//  LoginViewController.swift
//  Patriot
//
//  Created by Ron Lisle on 5/14/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    // Set by AppFactory
    var settings: Settings!
    var loginManager: LoggingIn!
    
    var user: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call factory to configure our dependencies
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            let appFactory = appDelegate.appFactory
            appFactory?.configureLogin(viewController: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performAutoLogin()
        updateDisplay()
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userPasswordVC = storyboard.instantiateViewController(withIdentifier: "UserPasswordViewController") as! UserPasswordViewController
        userPasswordVC.onComplete = { (user: String, password: String) in
            self.settings.particleUser = user
            self.settings.particlePassword = password
            self.loginManager.login(user: user, password: password, completion: { (error) in
                if let error = error {
                    print("Error logging in: \(error)")
                }
                self.updateDisplay()
            })
        }
        userPasswordVC.prevUser = settings.particleUser
        self.present(userPasswordVC, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        self.settings.particlePassword = ""
        loginManager.logout()
        updateDisplay()
    }
    
    func performAutoLogin() {
        if let user = settings.particleUser, let password = settings.particlePassword {
            loginManager.login(user: user, password: password) { (error) in
                if let error = error {
                    print("Error auto logging in: \(error)")
                }
                self.updateDisplay()

                //TODO: Delay 1 second then switch to Activities display after auto logging in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    if let tabBarController = self.tabBarController as? TabBarController {
                        tabBarController.selectActivitiesTab()
                    }
                }
            }
        }
    }
    
    func updateDisplay() {
        if (loginManager.isLoggedIn) {
            loginButton.isEnabled = false
            logoutButton.isEnabled = true
            label.text = "Login status: logged in"
            imageView.image = #imageLiteral(resourceName: "LightOn")
        } else {
            loginButton.isEnabled = true
            logoutButton.isEnabled = false
            label.text = "Login status: not logged in"
            imageView.image = #imageLiteral(resourceName: "LightOff")
        }
    }
}

