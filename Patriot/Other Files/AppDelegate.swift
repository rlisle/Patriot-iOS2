//
//  AppDelegate.swift
//  Patriot
//
//  Created by Ron Lisle on 5/14/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appFactory: AppFactory?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        appFactory = AppFactory(window: window!)
        
        return true
    }
}

