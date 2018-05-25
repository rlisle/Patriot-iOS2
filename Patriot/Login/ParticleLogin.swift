//
//  ParticleLogin.swift
//  Patriot
//
//  Created by Rons iMac on 5/13/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import Foundation
import Particle_SDK

class ParticleLogin: LoggingIn
{
    var isLoggedIn = false
    
    /**
     * Login to the particle.io account
     * The particle SDK will use the returned token in subsequent calls.
     * We don't have to save it.
     */
    func login(user: String, password: String, completion: @escaping (Error?) -> Void)
    {
        if !isLoggedIn {
        
            ParticleCloud.sharedInstance().login(withUser: user, password: password) { (error) in
                if error == nil {
                    self.isLoggedIn = true
                } else {
                    print ("Error logging in: \(error!)")
                    self.isLoggedIn = false
                }
                completion(error)
            }
        }
    }
    
    func logout()
    {
        ParticleCloud.sharedInstance().logout()
        isLoggedIn = false
    }
}
