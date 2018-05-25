//
//  SettingsStore.swift
//  ParticleLogin
//
//  This class implements LoginStore using UserDefaults
//
//  Created by Ron Lisle on 5/24/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import Foundation

class SettingsStore: LoginStore
{
    let userKey = "userKey"
    let passwordKey = "passwordKey"
    
    var userId: String?
    {
        get {
            let defaults = UserDefaults.standard
            return defaults.object(forKey: userKey) as? String
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: userKey)
        }
    }
    var password: String?
    {
        get {
            let defaults = UserDefaults.standard
            return defaults.object(forKey: passwordKey) as? String
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: passwordKey)
        }
    }
}
