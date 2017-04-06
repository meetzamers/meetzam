//
//  SettingViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/26/17.
//
//

import UIKit
import AWSMobileHubHelper
import FBSDKLoginKit

class SettingViewController: UIViewController {
    
    // ============================================
    // Variable starts here
    var new_signinObserver: AnyObject!
    var new_signoutObserver: AnyObject!
    
    fileprivate let loginStatusButton: UIButton = UIButton(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 65, width: UIScreen.main.bounds.width, height: 50))
    
    // Variable ends here
    // ============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // ============================================
        // Push notification cell:
        let pushNFCell: UIButton = UIButton()
        pushNFCell.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 50)
        pushNFCell.backgroundColor = UIColor.white
        pushNFCell.addTarget(self, action: #selector(toNotification), for: .touchUpInside)
        
        let pushNFLabel: UILabel = UILabel()
        pushNFLabel.text = "Receive Push Notifications"
        pushNFLabel.frame = CGRect(x: 15, y: 5, width: UIScreen.main.bounds.width - 70, height: 40)
        pushNFCell.addSubview(pushNFLabel)
        
        let pushNFNextImage: UIImageView = UIImageView()
        pushNFNextImage.frame = CGRect(x: UIScreen.main.bounds.width - 41, y: 9.5, width: 31, height: 31)
        pushNFNextImage.image = UIImage(named: "Next")
        pushNFNextImage.contentMode = .scaleAspectFit
        pushNFNextImage.alpha = 0.5
        pushNFCell.addSubview(pushNFNextImage)
        
        self.view.addSubview(pushNFCell)
        // ============================================
        // Clear cache cell:
        let clearCacheCell: UIButton = UIButton()
        clearCacheCell.frame = CGRect(x: 0, y: 115, width: UIScreen.main.bounds.width, height: 50)
        clearCacheCell.backgroundColor = UIColor.white
        clearCacheCell.addTarget(self, action: #selector(self.clearCacheAction), for: .touchUpInside)
        
        let clearCacheLabel: UILabel = UILabel()
        clearCacheLabel.text = "Clear Cache"
        clearCacheLabel.frame = CGRect(x: 15, y: 5, width: UIScreen.main.bounds.width - 70, height: 40)
        clearCacheCell.addSubview(clearCacheLabel)
        
        self.view.addSubview(clearCacheCell)
        // ============================================
        handleSigninStatus()
        
        // ============================================
        // AWS implementation starts here
        
        // 1. first attempt to pop sign in view controller
        perform(#selector(popSignInViewController), with: nil, afterDelay: 0)
        //popSignInViewController()
        
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
        
        // 3. signoutObserver: need to figure it out.
        new_signoutObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignOut,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard let strongSelf = self else { return }
                print("Sign Out Observer observed sign out.")
                strongSelf.setloginStatusButton()
        })
        
        // 4. attemp to add button
        self.setloginStatusButton()
        
        // AWS implementation ends here
        // ============================================
        
    }
    
    // ============================================
    // AWS support functions start here
    
    deinit {
        NotificationCenter.default.removeObserver(new_signinObserver)
        NotificationCenter.default.removeObserver(new_signoutObserver)
    }
    
    // 1. set login/logout button
    func setloginStatusButton() {
        
        loginStatusButton.setTitleColor(UIColor.red, for: .normal)
        
        loginStatusButton.setTitle("NONE", for: .normal)
        loginStatusButton.backgroundColor = UIColor.white
        loginStatusButton.tag = 1
        
        
        if (AWSIdentityManager.default().isLoggedIn) {
            loginStatusButton.setTitle("Log out", for: .normal)
            loginStatusButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
            
        }
        
        self.view.addSubview(loginStatusButton)
    }
    
    // 2. handle logout
    func handleLogout() {
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(
                completionHandler: { (result: Any?, error: Error?) in
                    let facebookCookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://login.facebook.com")!)
                    for cookie in facebookCookies! {
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                    
                    let provider = AWSFacebookSignInProvider.sharedInstance()
                    provider.clearCachedLoginFlag()
                    
                    self.setloginStatusButton()
                    //self.popSignInViewController()
                    self.animated_SignInViewController()
            })
        }
    }
    
    // 3. display sign in view controller
    func popSignInViewController() {
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            
            self.present(viewController, animated: false, completion: nil)
            
        }
    }
    
    func animated_SignInViewController() {
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            
            self.present(viewController, animated: true, completion: nil)
            
        }
    }
    
    // ============================================
    func handleSigninStatus() {
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    // ============================================
    // Notification button action:
    
    // to aws notification
    func toNotification(sender: UIButton!) {
        let storyboard = UIStoryboard(name: "PushNotification", bundle: nil)
        let VC1 = storyboard.instantiateViewController(withIdentifier: "AWSPushNoti")
        
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    // ============================================
    // Clear cache action:
    func clearCacheAction() {
        let alertView = UIAlertController(title: nil, message: "Clearing Cache...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alertView.view.addSubview(loadingIndicator)
        
        self.present(alertView, animated: true, completion: nil)
        
        picCache.removeAllObjects()
        
        
        
        alertView.dismiss(animated: true, completion: nil)
    }
}
