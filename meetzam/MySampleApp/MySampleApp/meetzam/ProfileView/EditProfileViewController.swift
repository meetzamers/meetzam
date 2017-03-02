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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    // User unique ID
    var dbID: String!
    
    // Profile picture
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Profile name
    @IBOutlet weak var name: UITextField!
    var dbName: String!
    
    // Profile bio
    @IBOutlet weak var bio: UITextField!
    var dbBio: String!
    
    // Profile email
    @IBOutlet weak var email: UITextField!
    var dbEmail: String!
    
    // Profile age
    @IBOutlet weak var age: UITextField!
    var dbAge: String!
    
    // Profile gender
    @IBOutlet weak var gender: UITextField!
    var dbGender: String!
    
    // Profile region
    @IBOutlet weak var region: UITextField!
    var dbRegion: String!
    
    // Change profile picture button
    @IBAction func changeProfilePictureButtonTapped(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.camera
        
        image.allowsEditing = true
        
        self.present(image, animated: true) {
            // After it is complete
        }
        
    }
    // Function used in change profile picture button
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
        } else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Save button
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dbName = name.text
        dbBio = bio.text
        dbEmail = email.text
        dbAge = age.text
        dbGender = gender.text
        dbRegion = region.text
        
        UserProfileToDB().insertProfile(_userId: dbID, _displayName: dbName, _bio: dbBio, _age: dbAge, _gender: dbGender, _region: dbRegion, _email: dbEmail)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let identityManager = AWSIdentityManager.default()
        AWSIdentityManager.default()
        
        // Initiating user's unique ID
        dbID = identityManager.identityId
        
        // Initiating name field from Facebook userName
        if let identityUserName = identityManager.userName {
            dbName=identityUserName
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
    
    
    /* Next four functions are for adjusting of textfield when keyboard shows up */
    @IBOutlet weak var scrollView: UIScrollView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let screenHeight = UIScreen.main.bounds.height
        scrollView.setContentOffset(CGPoint(x:0, y:(270-screenHeight+textField.frame.origin.y + textField.frame.height)), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
}
