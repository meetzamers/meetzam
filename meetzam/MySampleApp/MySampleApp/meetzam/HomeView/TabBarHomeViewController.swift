//
//  TabBarHomeViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/20/17.
//
//

import UIKit
import AWSMobileHubHelper

class TabBarHomeViewController: UIViewController {
    
    // ============================================
    // Variable starts here
    var new_signinObserver: AnyObject!
    
    fileprivate let loginStatusButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
    
    // Variable ends here
    // ============================================
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleSigninStatus()
        
        // ============================================
        // AWS implementation starts here
        
        // 1. first attempt to pop sign in view controller
         popSignInViewController()
        
        // 2. signinObserver: need to figure it out.
        new_signinObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard let strongSelf = self else { return }
                print("Sign in observer observed sign in.")
                strongSelf.setloginStatusButton()
                
            })
        
        
        
        // AWS implementation ends here
        // ============================================
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        popSignInViewController()
//        
//        new_signinObserver = NotificationCenter.default.addObserver(
//                    forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
//                    object: AWSIdentityManager.default(),
//                    queue: OperationQueue.main,
//                    using: { [weak self] (note: Notification) -> Void in
//                        guard let strongSelf = self else { return }
//                        print("Sign in observer observed sign in.")
//                        strongSelf.setloginStatusButton()
//                        
//                    })
//    }

    // ============================================
    // AWS support functions start here
    
    // 1. set login/logout button
    func setloginStatusButton() {
        
        loginStatusButton.setTitle("NONE", for: .normal)
        loginStatusButton.backgroundColor = UIColor.brown;
        loginStatusButton.tag = 1
        
        
        if (AWSIdentityManager.default().isLoggedIn) {
            loginStatusButton.setTitle("Log out", for: .normal)
            loginStatusButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        }
        
        self.view.addSubview(loginStatusButton)
    }
    
    func handleLogout() {
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(
                completionHandler: { (result: Any?, error: Error?) in
                    self.setloginStatusButton()
                    self.popSignInViewController()
                })
        }
        else {
            assert(false)
        }
    }
    
    func popSignInViewController() {
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            self.present(viewController, animated: true, completion: nil)

        }
    }
    
    
    // AWS support functions end here
    // ============================================
    // Debug functions start here
    // Simple debug function for update the login Status Label
    func handleSigninStatus() {
        if (AWSIdentityManager.default().isLoggedIn) {
            loginStatusLabel.text = "Already Signed in"
        }
        else {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            self.present(viewController, animated: true, completion: nil)
            updateLabel()
        }
    }
    
    // update the label
    func updateLabel() {
        loginStatusLabel.text = "Signed in with Facebook"
    }
    // Debug functions end here
    // ============================================

}
