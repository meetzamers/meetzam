//
//  EditProfileViewController.swift
//  MySampleApp
//
//  Created by Sean Chew on 2/22/17.
//
//

import UIKit

class EditProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
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
    
    // Profile age
    @IBOutlet weak var age: UITextField!
    
    // Profile gender
    @IBOutlet weak var gender: UITextField!

    // Profile region
    @IBOutlet weak var region: UITextField!
    
}
