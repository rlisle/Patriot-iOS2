//
//  UserPasswordViewController.swift
//  ParticleLogin
//
//  Created by Ron Lisle on 5/14/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import UIKit

class UserPasswordViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var containingView: UIView!
    
    var onComplete: ((String, String)->())?
    var prevUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containingView.layer.cornerRadius = 10
        containingView.clipsToBounds = true
        
        passwordTextField.delegate = self
        
        restorePreviousUserId()
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        performSubmit()
    }
    
    func restorePreviousUserId() {
        userTextField?.text = prevUser
    }
    
    func performSubmit() {
        if let user = userTextField.text,
        let password = passwordTextField.text {
            onComplete?(user, password)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UserPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        performSubmit()
        return true
    }
}
