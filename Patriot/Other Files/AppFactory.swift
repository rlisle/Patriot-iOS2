//
//  AppFactory.swift
//  Patriot
//
//  This module manages the creation and relationship between modules.
//  It is accessible from the AppDelegate.
//  It has a lifetime of the entire app.
//
//  Created by Ron Lisle on 11/4/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit

class AppFactory
{
    let window: UIWindow
    let hwManager = PhotonManager()
    let loginManager = ParticleLogin()
    let settings = Settings(store: UserDefaultsSettingsStore())
    
    init(window: UIWindow)
    {
        self.window = window
    }
    
    func configureLogin(viewController: LoginViewController)
    {
        viewController.settings = settings
        viewController.loginManager = loginManager
    }
    
    func configureActivities(viewController: ActivitiesViewController)
    {
        viewController.settings = settings
        let activitiesDataManager = ActivitiesDataManager(hardware: hwManager)
        viewController.dataManager = activitiesDataManager
        hwManager.activityDelegate = activitiesDataManager
        hwManager.deviceDelegate = activitiesDataManager
        activitiesDataManager.delegate = viewController
    }
}
