//
//  Device.swift
//  Patriot
//
//  Created by Ron Lisle on 5/31/18.
//  Copyright © 2018 Ron Lisle. All rights reserved.
//

import UIKit

protocol DeviceDelegate: AnyObject {
    func devicePercentChanged(name: String, type: DeviceType, percent: Int)
    func isFavoriteChanged(name: String, type: DeviceType, isFavorite: Bool)
}

class Device
{
    let name:          String
    var onImage:       UIImage
    var offImage:      UIImage
    var type:          DeviceType
    var percent:       Int             = 0
    var isFavorite:    Bool            = false
    weak var delegate: DeviceDelegate? = nil
    
    init(name: String, type: DeviceType) {
        self.name       = name
        self.type       = type
//        setImagesFor(type: type)
//    }
//
//    func setImagesFor(type: DeviceType) {
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

extension Device: Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
