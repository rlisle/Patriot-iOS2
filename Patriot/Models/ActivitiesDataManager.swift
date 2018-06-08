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
        self.hardware = hardware
        refresh(activities: hardware.activities)
    }


    func isActivityOn(at: Int) -> Bool
    {
        return activities[at].isActive
    }

    
    func toggleActivity(at: Int)
    {
        let toggledState = isActivityOn(at: at) ? false : true
        setActivity(at: at, isActive: toggledState)
    }

    
    func setActivity(at: Int, isActive: Bool)
    {
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
        for activityInfo in activities
        {
            self.activities.append(Activity(name: activityInfo.name, isActive: activityInfo.isActive))
        }
        delegate?.activitiesChanged()
    }
}


extension ActivitiesDataManager: ActivityNotifying
{
    func activitiesChanged()
    {
        let list = hardware.activities
        refresh(activities: list)
    }


    func activityChanged(name: String, isActive: Bool)
    {
        if let index = activities.index(where: {$0.name == name})
        {
            activities[index].isActive = isActive
            delegate?.activityChanged(name: name, isActive: isActive)
        }
    }
}
