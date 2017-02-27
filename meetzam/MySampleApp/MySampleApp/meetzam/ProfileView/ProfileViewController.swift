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
    
    // Go to setting page
    @IBAction func toSettingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSetSegue", sender: self)
    }

}
