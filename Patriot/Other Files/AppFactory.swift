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
    let settings: Settings
    
    init(window: UIWindow)
    {
        self.window = window
        photonManager = PhotonManager()
        mqttManager = MQTTManager()
        settings = Settings(store: UserDefaultsSettingsStore())
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
        let devicesManager = DevicesManager(photonManager: photonManager, mqtt: mqttManager)
        viewController.deviceManager = devicesManager
        photonManager.deviceDelegate = devicesManager
        devicesManager.delegate = viewController
    }

    func configureFavorites(viewController: FavoritesViewController)
    {
        viewController.settings = settings
        let devicesManager = DevicesManager(photonManager: photonManager, mqtt: mqttManager)
        viewController.deviceManager = devicesManager
        photonManager.deviceDelegate = devicesManager
        devicesManager.delegate = viewController
    }

}
