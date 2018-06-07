//
//  Photon.swift
//  Patriot
//
//  This class provides the interface to a Photon microcontroller.
//
//  The Photon will be interrogated to identify the devices and activities
//  that it implements using the published variables:
//
//      deviceNames     is a list of all the devices exposed on the Photon
//      supportedNames  is a list of all activities supported by the Photon
//      activities      is a list exposed by some Photons tracking current
//                      activity state based on what it has heard.
//                      TODO: switch to using the values function.
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
     * Refresh is expected to be called once after init and delegate is set
     */
    func refresh() -> Promise<Void>
    {
        print("refreshing \(name)")
        readPublishName() {
            print("publish name: \(self.publish)")
            refreshDevices()
            refreshSupported()
        }
    }
}

extension Photon    // Devices
{
    func refreshDevices()
    {
        devices = []
        readVariable("Devices") { (result: [String]) in
            self.parseDeviceNames(result)
        }
    }
    
    
    private func parseDeviceNames(_ deviceString: String) -> Promise<Void>
    {
        let items = deviceString.components(separatedBy: ",")
        guard items.count > 0 else {
            return Promise.value( () )
        }
        var promises = [Promise<Void>]()
        for item in items
        {
            let itemComponents = item.components(separatedBy: ":")
            let lcDevice = itemComponents[0].localizedLowercase
            
            //TODO: filter out duplicate device names
            
            //TODO: get actual device type & percent
            let promise1 = getDeviceType(device: lcDevice)
                .then { type -> Void in

                    //TODO: get actual current percent
                    let deviceInfo = DeviceInfo(name: lcDevice, type: type, percent: 0)
                    devices.append(deviceInfo)
                    delegate?.device(named: self.name, hasDevices: devices)
            }
            promises.append(promise)
        }
        return when(fulfilled: promises)
    }
    
    func getDeviceType(device: String) -> Promise<Int>
    {
        return callFunction(name: "type", args: [])
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


    func readVariable(_ name: String, completion: (String?) -> Void) -> String?
    {
        guard particleDevice.variables[name] != nil else
        {
            print("Variable \(name) doesn't exist on photon \(self.name)")
            completion(nil)
            return
        }
        particleDevice.getVariable(name) { (result: Any?, error: Error?) in
            completion(result as String?)
        }
    }
    
    func callFunction(name: String, args: [String]) -> Int?
    {
        particleDevice.callFunction(name, withArguments: args) { (result: Any?, error: Error?) in
            if let error = error {
                return nil
            }
            else
            {
                let value = result ?? 0
                return value
            }
        }
    }
}
