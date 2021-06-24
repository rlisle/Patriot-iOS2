//
//  Photon.swift
//  Patriot
//
//  This class provides the interface to a Photon microcontroller.
//
//  The Photon will be interrogated to identify the devices
//  that it implements using the published variables:
//
//      deviceNames     is a list of all the devices, types, and values exposed on the Photon
//
//      value(name: String) return the current device value
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
    }

    /**
     * Refresh is expected to be called once after init and delegate is set
     */
    func refresh()
    {
        refreshDevices()
    }
}

extension Photon    // Devices
{
    func refreshDevices()
    {
        devices = []
        readVariable("Devices") { (result) in
            if let result = result {
                self.parseDeviceNames(result)
            }
        }
    }
    
    
    private func parseDeviceNames(_ deviceString: String)
    {
        print("parseDeviceNames: \(deviceString)")
        let items = deviceString.components(separatedBy: ",")
        for item in items
        {
            let lcDevice = item.localizedLowercase

            getDeviceType(device: lcDevice) { (type) in
                
                self.getDevicePercent(device: lcDevice) { (percent) in
                    print("getDevicePercent \(lcDevice) = \(percent)")
                    let deviceInfo = DeviceInfo(name: lcDevice, type: type, percent: percent)
                    self.devices.append(deviceInfo)
                    self.delegate?.device(named: self.name, hasDevices: self.devices)
                }
            }
        }
    }
    
    func getDeviceType(device: String, completion: @escaping (DeviceType) -> Void)
    {
        callFunction(name: "type", args: [device]) { (result) in
            let value = result ?? 0
            completion(DeviceType(rawValue: value)!)
        }
    }
    
    func getDevicePercent(device: String, completion: @escaping (Int) -> Void)
    {
        callFunction(name: "value", args: [device]) { (result) in
            let value = result ?? 0
            completion(value)
        }
    }
}

extension Photon        // Read variables
{
    func readVariable(_ name: String, completion: @escaping (String?) -> Void)
    {
        guard particleDevice.variables[name] != nil else
        {
            print("Variable \(name) doesn't exist on photon \(self.name)")
            completion(nil)
            return
        }
        particleDevice.getVariable(name) { (result: Any?, error: Error?) in
            completion(result as? String)
        }
    }
    
    func callFunction(name: String, args: [String], completion: @escaping (Int?) -> Void)
    {
        particleDevice.callFunction(name, withArguments: args) { (result: NSNumber?, error: Error?) in
            completion(result as? Int)
        }
    }
}
