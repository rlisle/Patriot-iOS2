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
    
    var store: LoginStore = SettingsStore()
    let loginManager: LoggingIn = ParticleLogin()
    
    var user: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performAutoLogin()
        updateDisplay()
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userPasswordVC = storyboard.instantiateViewController(withIdentifier: "UserPasswordViewController") as! UserPasswordViewController
        userPasswordVC.onComplete = { (user: String, password: String) in
            self.store.userId = user
            self.store.password = password
            self.loginManager.login(user: user, password: password, completion: { (error) in
                if let error = error {
                    print("Error logging in: \(error)")
                }
                self.updateDisplay()
            })
        }
        userPasswordVC.prevUser = store.userId
        self.present(userPasswordVC, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        self.store.password = nil
        loginManager.logout()
        updateDisplay()
    }
    
    func performAutoLogin() {
        if let user = store.userId, let password = store.password {
            loginManager.login(user: user, password: password) { (error) in
                if let error = error {
                    print("Error auto logging in: \(error)")
                }
                self.updateDisplay()

                //TODO: Delay 1 second then switch to Activities display after auto logging in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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

