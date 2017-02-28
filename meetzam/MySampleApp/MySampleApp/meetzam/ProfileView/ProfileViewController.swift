//
//  ProfileViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit
import Foundation
import AWSMobileHubHelper

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameAndAgeField: UILabel!
    @IBOutlet weak var userBioField: UILabel!
    @IBOutlet weak var userPicField: UIImageView!
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let identityManager = AWSIdentityManager.default()
        
        AWSIdentityManager.default()
        
        
        if let identityUserName = identityManager.userName {
            //if let identityAge = identityManager.
            
            displayNameAndAgeField.text = identityUserName
            
            //displayNameAndAgeField.text = identityUserName
        } else {
            displayNameAndAgeField.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        
        userBioField.text = "Hello! :)"
        
        
        
        if let imageURL = identityManager.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                userPicField.image = profileImage
            } else {
                userPicField.image = UIImage(named: "UserIcon")
            }
        }
        
        

        
    }
    
    // Go to all movies I liked
    @IBAction func toAllMovies(_ sender: Any) {
        self.performSegue(withIdentifier: "toMovies", sender: self)
        
    }
    // Go to setting page
    @IBAction func toSettingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSetSegue", sender: self)
    }

}
