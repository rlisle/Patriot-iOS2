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

        delegate = self
        selectLoginTab()
    }
    
    func selectActivitiesTab() {
        selectedIndex = 0
    }
    
    func selectDevicesTab() {
        selectedIndex = 1
    }
    
    func selectLoginTab() {
        selectedIndex = 2
    }
    
//    func animateToTab(toIndex: Int) {
//        let tabViewControllers = viewControllers!
//        let fromView = selectedViewController!.view
//        let toView = tabViewControllers[toIndex].view
//        let fromIndex = tabViewControllers.indexOf(selectedViewController!)
//
//        guard fromIndex != toIndex else {return}
//
//        // Add the toView to the tab bar view
//        fromView.superview!.addSubview(toView)
//
//        // Position toView off screen (to the left/right of fromView)
//        let screenWidth = UIScreen.mainScreen().bounds.size.width;
//        let scrollRight = toIndex > fromIndex;
//        let offset = (scrollRight ? screenWidth : -screenWidth)
//        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
//
//        // Disable interaction during animation
//        view.userInteractionEnabled = false
//
//        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//
//            // Slide the views by -offset
//            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
//            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
//
//        }, completion: { finished in
//
//            // Remove the old view from the tabbar view.
//            fromView.removeFromSuperview()
//            self.selectedIndex = toIndex
//            self.view.userInteractionEnabled = true
//        })
//    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        print("tabBarController shouldSelect called")
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        let tabViewControllers = viewControllers!
        let fromIndex = tabViewControllers.index(of: selectedViewController!)!   // YOLO
        let toIndex = tabViewControllers.index(of: viewController)!
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
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
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
