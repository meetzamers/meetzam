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
    
    @IBOutlet weak var loginStatusLabel: UILabel!

    @IBAction func debugButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toDemoHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSigninStatus()
    }
    
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
    
    func updateLabel() {
        loginStatusLabel.text = "Signed in with Facebook"
    }

}
