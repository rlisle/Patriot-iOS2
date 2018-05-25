//
//  LoginStore.swift
//  ParticleLogin
//
//  This protocol defines the interface to persist the user's ID and password
//
//  Created by Ron Lisle on 5/24/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import Foundation

protocol LoginStore
{
    var userId: String? { get set }
    var password: String? { get set }
}
