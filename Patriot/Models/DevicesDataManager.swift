//
//  DevicesDataManager.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit

class DevicesDataManager
{
    var devices:        [ Device ] = []
    let hardware:       HwManager
    weak var delegate:  DeviceNotifying?
    
    init(hardware: HwManager)
    {
        print("DevicesDataManager init")
        self.hardware = hardware
        
        devices.append(Device(name: "office", percent: 0))
        
        refresh(supported: hardware.deviceNames)
    }


    func isDeviceOn(at: Int) -> Bool
    {
        return devices[at].percent > 0
    }

    
    func toggleActivity(at: Int)
    {
        let isOn = isActivityOn(at: at)
        print("toggleActivity to \(isOn ? 0 : 100)")
        setActivity(at: at, percent: isOn ? 0 : 100)
    }

    
    func setActivity(at: Int, percent: Int)
    {
        print("DM set activity at: \(at) to \(percent)")
        activities[at].percent = percent
        let name = activities[at].name
        hardware.sendCommand(activity: name, percent: percent) { (error) in
            if let error = error {
                print("Send command error: \(error)")
            }
        }
    }
}


//MARK: Helper Methods

extension ActivitiesDataManager
{
    func refresh(supported: Set<String>)
    {
        print("refresh: \(supported)")
        for name in supported
        {
            print("ActivitiesDM: Adding activity \(name)")
            self.activities.append(Activity(name: name, percent: 0))
            
            //TODO: determine actual initial activity state. It might be on.
            
        }
        delegate?.supportedListChanged()
    }
}


extension ActivitiesDataManager: ActivityNotifying
{
    func supportedListChanged()
    {
        print("ActivitiesDataManager supportedListChanged")
        let list = hardware.supportedNames
        refresh(supported: list)
    }


    func activityChanged(name: String, percent: Int)
    {
        print("ActivityDataManager: ActivityChanged: \(name)")
        if let index = activities.index(where: {$0.name == name})
        {
            print("   index of activity = \(index)")
            activities[index].percent = percent
        }
        delegate?.activityChanged(name: name, percent: percent)
    }
}
