//
//  DevicesDataManager.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit

class DevicesManager
{
    var devices:        [ Device ] = []
    let photonManager:  PhotonManager
    let mqtt:           MQTTManager
    weak var delegate:  DeviceNotifying?
    
    init(photonManager: PhotonManager, mqtt: MQTTManager)
    {
        print("DevicesManager init")
        self.photonManager = photonManager
        self.mqtt = mqtt
        mqtt.deviceDelegate = self
        
        devices.append(Device(name: "office", percent: 0))  // Huh?
        
        refresh(devices: photonManager.devices)
    }


    func isDeviceOn(at: Int) -> Bool
    {
        return devices[at].percent > 0
    }

    
    func toggleDevice(at: Int)
    {
        let isOn = isDeviceOn(at: at)
        print("toggleDevice to \(isOn ? 0 : 100)")
        setDevice(at: at, percent: isOn ? 0 : 100)
    }

    
    func setDevice(at: Int, percent: Int)
    {
        print("DevicesManager set device at: \(at) to \(percent)")
        devices[at].percent = percent
        let name = devices[at].name
        if mqtt.isConnected {
            mqtt.sendPatriotMessage(device: name, percent: percent)
        } else {
            photonManager.sendCommand(device: name, percent: percent) { (error) in
                if let error = error {
                    print("Send command error: \(error)")
                }
            }
        }
    }
}

//MARK: Helper Methods

extension DevicesManager
{
    func refresh(devices: [DeviceInfo])
    {
        self.devices = []
        for device in devices
        {
            let name = device.name
            let percent = device.percent
            self.devices.append(Device(name: name, percent: percent))
        }
        delegate?.deviceListChanged()
    }
}


extension DevicesManager: DeviceNotifying
{
    func deviceListChanged()
    {
        print("DevicesManager deviceListChanged")
        let list = photonManager.devices
        refresh(devices: list)
    }


    func deviceChanged(name: String, percent: Int)
    {
        print("DeviceManager: DeviceChanged: \(name)")
        if let index = devices.firstIndex(where: {$0.name == name})
        {
            print("   index of device = \(index)")
            devices[index].percent = percent
        }
        delegate?.deviceChanged(name: name, percent: percent)
    }
}