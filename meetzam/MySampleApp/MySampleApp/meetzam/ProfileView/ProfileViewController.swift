//
//  ProfileViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func connect(_ sender: Any) {
        MUserProfile().insertSomeItems("1", "Mary", "I love movies!", "25", "female", "IN", "mary@gmail.com")
        
    }

}
