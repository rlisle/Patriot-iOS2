//
//  Photon.swift
//  Patriot
//
//  This class provides the interface to a Photon device.
//
//  The photon will be interrogated to identify the devices and activities
//  that it supports:
//
//  DeviceInfo is a struct containing:
//      name: String    the name of the device
//      type: enum      the device type
//      percent: Int    the current device percent value
//  ActivityInfo is a struct containing info about each activity:
//      name: String    the name of the activity
//      isActive: Bool  the current percent value (0=off, 100=on)
//
//  TODO: replace these with devices and activity collections
//      deviceNames     is a list of all the devices exposed on the Photon
//      supportedNames  is a list of all activities supported by the Photon
//      activities      is a list exposed by some Photons tracking current
//                      activity state based on what it has heard.
//
//      value(name: String) return the current device/activity value
//      type(name: String) returns the device type
//
//  This file uses the Particle SDK:
//      https://docs.particle.io/reference/ios/#common-tasks
//
//  Created by Ron Lisle on 4/17/17
//  Copyright © 2016, 2017 Ron Lisle. All rights reserved.
//

import Foundation
import Particle_SDK
import PromiseKit


enum DeviceType {
    case Unknown
    case Fan
    case Light
    case Motor
    case NCD8Relay  //placeholder
    case Presence
    case Relay
    case Switch
    case TempHumidity
    case Ultrasonic
}

struct DeviceInfo {
    var name: String
    var type: DeviceType
    var percent: Int
}

struct ActivityInfo {
    var name: String
    var isActive: Bool
}


// Public interface
class Photon: HwController
{
    let uninitializedString = "uninitialized"
    
    var devices: [DeviceInfo] = []      // Cached list of device names exposed by Photon
    var activities: [ActivityInfo] = [] // Optional list of current activities and state
    var publish: String                 // Publish event name that this device monitors
    
    var delegate: PhotonNotifying?      // Notifies manager when status changes
    

    internal let particleDevice: ParticleDevice! // Reference to Particle-SDK device object
    
    
    var name: String
    {
        get {
            return particleDevice.name ?? "unknown"
        }
    }
    
    
    required init(device: ParticleDevice)
    {
        particleDevice  = device
        publish         = uninitializedString
    }

    /**
     * Refresh is expected to be called once after init
     * after delegate is set, etc.
     */
    func refresh() -> Promise<Void>
    {
        print("refreshing \(name)")
        let publishPromise = readPublishName()
        let devicesPromise = refreshDevices()
        let supportedPromise = self.refreshSupported()
        let promises = [ publishPromise, devicesPromise, supportedPromise, activitiesPromise ]
        return when(fulfilled: promises)
    }
}

extension Photon    // Devices
{
    func refreshDevices() -> Promise<Void>
    {
        devices = []
        return readVariable("Devices")
        .then { result -> Void in
            self.devices = []
            self.parseDeviceNames(result!)
        }
    }
    
    
    private func parseDeviceNames(_ deviceString: String)
    {
        let items = deviceString.components(separatedBy: ",")
        guard items.count > 0 else {
            return
        }
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcDevice = itemComponents[0].localizedLowercase
            //TODO: get actual device type & percent
            let deviceInfo = DeviceInfo(name: lcDevice, type: .Light, percent: 0)
            devices.append(deviceInfo)
        }
        delegate?.device(named: self.name, hasDevices: devices)
    }
}

extension Photon    // Activities
{
    func refreshSupported() -> Promise<Void>
    {
        activities = []
        return readVariable("Supported")
        .then { result -> Void in
            self.parseSupported(result!)
        }
    }
    
    
    private func parseSupported(_ supportedString: String)
    {
        print("parseSupported: \(supportedString)")
        let items = supportedString.components(separatedBy: ",")
        guard items.count > 0 else {
            return
        }
        for item in items
        {
            let lcActivity = item.localizedLowercase
            let activityInfo = ActivityInfo(name: lcActivity, isActive: false)
            activities.append(activityInfo)
        }
        print("calling device \(self.name) hasActivities \(activities)")
        delegate?.device(named: self.name, hasActivities: activities)
    }
}

extension Photon        // Read variables
{
    func readPublishName() -> Promise<Void>
    {
        return readVariable("PublishName")
        .then { result -> Void in
            self.publish = result ?? self.uninitializedString
        }
    }


    func readVariable(_ name: String) -> Promise<String?>
    {
        return Promise { fulfill, reject in
            guard particleDevice.variables[name] != nil else
            {
                print("Variable \(name) doesn't exist on photon \(self.name)")
                
                return fulfill(nil)
            }
            particleDevice.getVariable(name) { (result: Any?, error: Error?) in
                if let error = error {
                    reject(error)
                }
                else
                {
                    fulfill(result as? String)
                }
            }
        }
    }
}
