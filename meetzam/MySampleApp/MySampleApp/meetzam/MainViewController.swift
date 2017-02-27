//
//  MainViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/26/17.
//
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // Tab bar style
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = 46
        tabFrame.origin.y = self.view.frame.size.height - 46
        self.tabBar.frame = tabFrame
        self.tabBar.tintColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    }
    
    // tap match pop up.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tabBarControllers = tabBarController.viewControllers!
        guard let toIndex = tabBarControllers.index(of: viewController) else {
            return false
        }
        
        if (toIndex == 2) {
            animateToTab(toIndex: toIndex)
        }
        return true
    }
    
    // animation pop up
    func animateToTab(toIndex: Int) {
        let tabViewControllers = viewControllers!
        let fromView = selectedViewController!.view
        let toView = tabViewControllers[toIndex].view
        let fromIndex = tabViewControllers.index(of: selectedViewController!)
        
        guard fromIndex != toIndex else {return}
        
        // Add the toView to the tab bar view
        fromView?.superview!.addSubview(toView!)
        
        // Position toView off screen (to the left/right of fromView)
        let screenHeight = UIScreen.main.bounds.size.height;
        let offset = -screenHeight
        
        toView?.center = CGPoint(x: (fromView?.center.x)!, y: (toView?.center.y)! + offset)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            // Slide the views by -offset
            fromView?.center = CGPoint(x: (fromView?.center.x)!, y: (fromView?.center.y)! + offset);
            toView?.center   = CGPoint(x: (toView?.center.x)!, y: (toView?.center.y)! + offset);
            
        }, completion: { finished in
            // Remove the old view from the tabbar view.
            fromView?.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
    
//    // animation dismiss
//    func animateDismiss(toIndex: Int) {
//        let tabViewControllers = viewControllers!
//        let fromView = selectedViewController!.view
//        let toView = tabViewControllers[toIndex].view
//        let fromIndex = tabViewControllers.index(of: selectedViewController!)
//        
//        guard fromIndex != toIndex else {return}
//        
//        // Add the toView to the tab bar view
//        fromView?.superview!.addSubview(toView!)
//        
//        // Position toView off screen (to the left/right of fromView)
//        let screenHeight = UIScreen.main.bounds.size.height;
//        let offset = screenHeight
//        
//        toView?.center = CGPoint(x: (fromView?.center.x)!, y: (toView?.center.y)! + offset)
//        
//        // Disable interaction during animation
//        view.isUserInteractionEnabled = false
//        
//        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
//            // Slide the views by -offset
//            fromView?.center = CGPoint(x: (fromView?.center.x)!, y: (fromView?.center.y)! + offset);
//            toView?.center   = CGPoint(x: (toView?.center.x)!, y: (toView?.center.y)! + offset);
//            
//        }, completion: { finished in
//            // Remove the old view from the tabbar view.
//            fromView?.removeFromSuperview()
//            self.selectedIndex = toIndex
//            self.view.isUserInteractionEnabled = true
//        })
//    }
    
}
