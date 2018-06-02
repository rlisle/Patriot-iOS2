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
        refresh(activities: hardware.activities)
    }


    func isActivityOn(at: Int) -> Bool
    {
        return activities[at].isActive
    }

    
    func toggleActivity(at: Int)
    {
        let toggledState = isActivityOn(at: at) ? false : true
        print("toggleActivity to \(toggledState)")
        setActivity(at: at, isActive: toggledState)
    }

    
    func setActivity(at: Int, isActive: Bool)
    {
        print("DM set activity at: \(at) to \(isActive)")
        activities[at].isActive = isActive
        let name = activities[at].name
        hardware.sendCommand(activity: name, isActive: isActive) { (error) in
            if let error = error {
                print("Send command error: \(error)")
            }
        }
    }
}


//MARK: Helper Methods

extension ActivitiesDataManager
{
    func refresh(activities: [ActivityInfo])
    {
        print("refresh: \(activities)")
        for activityInfo in activities
        {
            print("ActivitiesDM: Adding activity \(activityInfo.name)")
            self.activities.append(Activity(name: activityInfo.name, isActive: activityInfo.isActive))
        }
        delegate?.activitiesChanged()
    }
}


extension ActivitiesDataManager: ActivityNotifying
{
    func activitiesChanged()
    {
        print("ActivitiesDataManager activitiesChanged")
        let list = hardware.activities
        refresh(activities: list)
    }


    func activityChanged(name: String, isActive: Bool)
    {
        print("ActivityDataManager: ActivityChanged: \(name) = \(isActive)")
        if let index = activities.index(where: {$0.name == name})
        {
            print("   index of activity = \(index)")
            activities[index].isActive = isActive
            delegate?.activityChanged(name: name, isActive: isActive)
        }
    }
}
