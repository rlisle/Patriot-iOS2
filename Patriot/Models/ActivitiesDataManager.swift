//
//  ActivitiesDataManager.swift
//  Patriot
//
//  Created by Ron Lisle on 11/5/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import UIKit

class ActivitiesDataManager
{
    var activities:     [ Activity ] = []
    let hardware:       HwManager
    weak var delegate:  ActivityNotifying?
    
    init(hardware: HwManager)
    {
        print("ActivitiesDataManager init")
        self.hardware = hardware
//        activities.append(Activity(name: "booth", percent: 0))
//        activities.append(Activity(name: "coffee", percent: 0))
//        activities.append(Activity(name: "computer", percent: 0))
//        activities.append(Activity(name: "ronslight", percent: 0))
//        activities.append(Activity(name: "shelleyslight", percent: 0))
//        activities.append(Activity(name: "piano", percent: 0))
//        activities.append(Activity(name: "tv", percent: 0))
//        activities.append(Activity(name: "dishes", percent: 0))
        refresh(supported: hardware.supportedNames)
    }


    func isActivityOn(at: Int) -> Bool
    {
        return activities[at].percent > 0
    }

    
    func toggleActivity(at: Int)
    {
        let isOn = isActivityOn(at: at)
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


extension ActivitiesDataManager: DeviceNotifying
{
    func deviceFound(name: String)
    {
        print("Device found: \(name)")
        //Currently not really doing anything with this.
        //This will become important once we allow the app to 
        //configure/program device activites
    }
    
    
    func deviceLost(name: String)
    {
        print("Device lost: \(name)")
        //Ditto above
    }
}
