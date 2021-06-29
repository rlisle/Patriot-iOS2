//
//  PhotonNotifying.swift
//  Patriot
//
//  Created by Ron Lisle on 5/30/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import Foundation

protocol PhotonNotifying
{
    func photon(named: String, hasDevices: [DeviceInfo])
}
