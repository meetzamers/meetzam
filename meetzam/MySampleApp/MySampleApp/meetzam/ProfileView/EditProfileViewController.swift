//
//  EditProfileViewController.swift
//  MySampleApp
//
//  Created by Sean Chew on 2/22/17.
//
//

import UIKit
import Foundation
import AWSMobileHubHelper

class EditProfileViewController: UIViewController {
    // Profile picture
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Change profile picture button
    @IBAction func editProfilePictureButtonTapped(_ sender: UIButton) {
    }
    
    // Profile name
    @IBOutlet weak var name: UITextField!
    
    // Profile bio
    @IBOutlet weak var bio: UITextField!
    
    // Profile email
    @IBOutlet weak var email: UITextField!
    
    // Profile age3
    @IBOutlet weak var age: UITextField!
    
    // Profile gender
    @IBOutlet weak var gender: UITextField!
    
    // Profile region
    @IBOutlet weak var region: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let identityManager = AWSIdentityManager.default()
        
        AWSIdentityManager.default()
        
        // Initiating name field from Facebook userName
        if let identityUserName = identityManager.userName {
            name.text = identityUserName
        } else {
            name.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        
        // Initiating profilePicture UIImageView from Facebook profile picture
        if let imageURL = identityManager.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                profilePicture.image = profileImage
            } else {
                profilePicture.image = UIImage(named: "UserIcon")
            }
        }
        
    }
    
}
