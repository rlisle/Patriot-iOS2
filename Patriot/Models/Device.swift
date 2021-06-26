//
//  Device.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit


class Device
{
    let name:       String
    var onImage:    UIImage
    var offImage:   UIImage
    var type:       DeviceType
    var percent:    Int
    
    init(name: String, type: DeviceType, percent: Int = 0) {
        self.name    = name
        self.percent = percent
        self.type    = type
        //TODO: Set appropriate image based on type
        switch type {
        case .Curtain:
            self.onImage = #imageLiteral(resourceName: "CurtainOpen")
            self.offImage = #imageLiteral(resourceName: "CurtainClosed")
        case .Switch:
            self.onImage = #imageLiteral(resourceName: "SwitchOn")
            self.offImage = #imageLiteral(resourceName: "SwitchOff")
        default:
            self.onImage = #imageLiteral(resourceName: "LightOn")
            self.offImage = #imageLiteral(resourceName: "LightOff")
        }
    }
}
