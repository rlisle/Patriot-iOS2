//
//  HwManager.swift
//  Patriot
//
//  The HwManager has app lifetime so is held by the appFactory.
//  It can be accessed via the AppFactory
//
//  Created by Ron Lisle on 5/4/17.
//  Copyright © 2017 Ron Lisle. All rights reserved.
//

import Foundation
import PromiseKit


protocol HwManager: class
{
    var deviceDelegate:         DeviceNotifying?    { get set }
    var activityDelegate:       ActivityNotifying?  { get set }
    var eventName:              String              { get }
    var deviceNames:            Set<String>         { get }
    var supportedNames:         Set<String>         { get }
    var currentActivities:      [String: Int]       { get }
    
    func sendCommand(activity: String, percent: Int, completion: @escaping (Error?) -> Void)
    func sendCommand(device: String, percent: Int, completion: @escaping (Error?) -> Void)
}
