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
 
    @IBOutlet weak var firstMovie: UIImageView!
    @IBOutlet weak var secondMovie: UIImageView!
    @IBOutlet weak var thirdMovie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let identityManager = AWSIdentityManager.default()
        
        //AWSIdentityManager.default()
        
        if let identityUserName = identityManager.userName {
            displayNameAndAgeField.text = identityUserName
            
        } else {
            displayNameAndAgeField.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        
        userBioField.text = "Hello! :)"
        
        
        
        if let imageURL = identityManager.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                userPicField.image = profileImage
                
                firstMovie.image = UIImage(named: "lala")
                firstMovie.contentMode = .scaleAspectFill   // Ryan: Let the image aspect fit the UIImageView size
        
                secondMovie.image = UIImage(named: "John")
                secondMovie.contentMode = .scaleAspectFill  // Ryan: Let the image aspect fit the UIImageView size
                
                thirdMovie.image = UIImage(named: "loganposter2")
                thirdMovie.contentMode = .scaleAspectFill   // Ryan: Let the image aspect fit the UIImageView size
                
                
            } else {
                userPicField.image = UIImage(named: "UserIcon")
            }
        }
    }
    
    // Ryan: Edit button clicked action
    @IBAction func toEditProfilePage(_ sender: Any) {
        self.performSegue(withIdentifier: "toEditProfileSegue", sender: self)
    }
    
    // Ryan: More button clicked action
    @IBAction func moreButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toDetailedMovies", sender: self)
    }
    
    // Go to setting page
    @IBAction func toSettingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSetSegue", sender: self)
    }

}
