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
    let photonManager: PhotonManager
    let mqttManager: MQTTManager
    let devicesManager: DevicesManager
    let settings: Settings
    
    init(window: UIWindow)
    {
        self.window = window
        settings = Settings(store: UserDefaultsSettingsStore())
        photonManager = PhotonManager()
        mqttManager = MQTTManager()
        devicesManager = DevicesManager(photonManager: photonManager, mqtt: mqttManager, settings: settings)
        photonManager.deviceDelegate = devicesManager   // retain cycle?
    }
    
    func configureLogin(viewController: LoginViewController)
    {
        viewController.settings = settings
        viewController.loginManager = photonManager
        viewController.mqttManager = mqttManager
    }
    
    func configureDevices(viewController: DevicesViewController)
    {
        viewController.settings = settings
        viewController.deviceManager = devicesManager
        devicesManager.delegate = viewController        // Uh-oh, can't have 2 delegates, so need to do this is viewDidLoad
    }

    func configureFavorites(viewController: FavoritesViewController)
    {
        viewController.settings = settings
        viewController.deviceManager = devicesManager
        devicesManager.delegate = viewController        // Uh-oh, can't have 2 delegates
    }

}
