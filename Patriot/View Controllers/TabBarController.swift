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

    let favoritesIndex = 0
    let devicesIndex = 1
    let loginIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        selectedIndex = loginIndex
    }
    
    func selectFavoritesTab() {
        print("selectFavoritesTab")
        animateToTab(toIndex: favoritesIndex)
    }
    
    func selectDevicesTab() {
        print("selectDevicesTab")
        animateToTab(toIndex: devicesIndex)
    }
    
    func selectLoginTab() {
        print("selectLoginTab")
        animateToTab(toIndex: loginIndex)
    }
    
    func animateToTab(toIndex: Int) {
        let tabViewControllers = viewControllers!
        let toViewController = tabViewControllers[toIndex]
        _ = animateToTab(viewController: toViewController)
    }
    
    func animateToTab(viewController: UIViewController) -> Bool {
        print("animateToTab viewController")
        print("selectedViewController = \(String(describing: selectedViewController))")
        guard let fromView = selectedViewController?.view else {
            return false
        }
        print("viewController = \(viewController)") // Maybe lazy loading is throwing?
        guard let toView = viewController.view else {
            return false
        }
        let tabViewControllers = viewControllers!
        let fromIndex = tabViewControllers.firstIndex(of: selectedViewController!)!   // YOLO
        let toIndex = tabViewControllers.firstIndex(of: viewController)!
        guard fromIndex != toIndex else {return false}
        
        // Add the toView to the tab bar view
        fromView.superview!.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width;
        let scrollRight = toIndex > fromIndex;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            // Slide the views by -offset
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
            
        }, completion: { finished in
            
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
        return true
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("tabBarController shouldSelect called")
        return animateToTab(viewController: viewController)
    }

}
