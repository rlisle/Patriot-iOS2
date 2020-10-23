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
    let hwManager: PhotonManager
    let mqttManager: MQTTManager
    let settings: Settings
    
    init(window: UIWindow)
    {
        self.window = window
        hwManager = PhotonManager()
        mqttManager = MQTTManager()
        settings = Settings(store: UserDefaultsSettingsStore())
    }
    
    func configureLogin(viewController: LoginViewController)
    {
        viewController.settings = settings
        viewController.loginManager = hwManager
        viewController.mqttManager = mqttManager
    }
    
    func configureActivities(viewController: ActivitiesViewController)
    {
        viewController.settings = settings
        let activitiesDataManager = ActivitiesDataManager(hardware: hwManager)
        viewController.dataManager = activitiesDataManager
        hwManager.activityDelegate = activitiesDataManager
        activitiesDataManager.delegate = viewController
    }
    
    func configureDevices(viewController: DevicesViewController)
    {
        viewController.settings = settings
        let devicesDataManager = DevicesDataManager(hardware: hwManager, mqtt: mqttManager)
        viewController.dataManager = devicesDataManager
        hwManager.deviceDelegate = devicesDataManager
        devicesDataManager.delegate = viewController
    }

}
