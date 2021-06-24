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
            // Format is now type:name=value ("P|C|L|S|:<name>=<0-255>")
            let separatedByColon = item.components(separatedBy: ":")
            let separatedByEquals = separatedByColon[1].components(separatedBy: "=")
            
            let deviceType = DeviceType(rawValue: separatedByColon[0]) ?? DeviceType.Unknown
            let deviceName = separatedByEquals[0].localizedLowercase
            let deviceValue = Int(separatedByEquals[1]) ?? 0
            let deviceInfo = DeviceInfo(name: deviceName,
                                        type: deviceType,
                                        percent: deviceValue )
            devices.append(deviceInfo)
            delegate?.device(named: self.name, hasDevices: self.devices)
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
