//
//  TabBarController.swift
//  Patriot
//
//  This class determines the initial tab to display.
//  depending on whether or not the user has previously
//  logged in.
//
//  Created by Ron Lisle on 5/27/18.
//  Copyright © 2018 Rons iMac. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedIndex = 2
    }
}
