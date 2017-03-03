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
    // User profile (for database use)
    var user_profile: UserProfileToDB?
    
    // Change profile picture button
    @IBAction func changeProfilePictureButtonTapped(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
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
        UserProfileToDB().getProfileForEdit(key: AWSIdentityManager.default().identityId!, user_profile:user_profile, displayname: name, bio: bio, age: age, gender: gender, region: region, email: email)
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // Ryan: padding left space to the text
        let paddingView1 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
        paddingView1.image = UIImage(named: "NameIcon")
        paddingView1.contentMode = .scaleAspectFit
        paddingView1.isOpaque = false
        paddingView1.alpha = 0.7
        name.leftView = paddingView1
        name.leftViewMode = .always
        
        let paddingView2 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
        paddingView2.image = UIImage(named: "BioIcon")
        paddingView2.contentMode = .scaleAspectFit
        paddingView2.isOpaque = false
        paddingView2.alpha = 0.7
        bio.leftView = paddingView2
        bio.leftViewMode = .always
        
        let paddingView3 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 17))
        paddingView3.image = UIImage(named: "EmailIcon")
        paddingView3.contentMode = .scaleAspectFit
        paddingView3.isOpaque = false
        paddingView3.alpha = 0.7
        email.leftView = paddingView3
        email.leftViewMode = .always
        
        let paddingView4 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 17))
        paddingView4.image = UIImage(named: "AgeIcon")
        paddingView4.contentMode = .scaleAspectFit
        paddingView4.isOpaque = false
        paddingView4.alpha = 0.7
        age.leftView = paddingView4
        age.leftViewMode = .always
        
        let paddingView5 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
        paddingView5.image = UIImage(named: "GenderIcon")
        paddingView5.contentMode = .scaleAspectFit
        paddingView5.isOpaque = false
        paddingView5.alpha = 0.7
        gender.leftView = paddingView5
        gender.leftViewMode = .always
        
        let paddingView6 = UIImageView(frame: CGRect(x: 10, y: 0, width: 40, height: 17))
        paddingView6.image = UIImage(named: "RegionIcon")
        paddingView6.contentMode = .scaleAspectFit
        paddingView6.isOpaque = false
        paddingView6.alpha = 0.7
        region.leftView = paddingView6
        region.leftViewMode = .always
        // Ryan: padding left space to the text END
        
        
        let identityManager = AWSIdentityManager.default()
        AWSIdentityManager.default()
        
        // Initiating user's unique ID
        dbID = identityManager.identityId
        
        /* Get all the info from database, if nil, get from fb  */
        UserProfileToDB().getProfileForEdit(key: AWSIdentityManager.default().identityId!, user_profile:user_profile, displayname: name, bio: bio, age: age, gender: gender, region: region, email: email)
        
        /* Added an if statement -- only get from facebook when username is nil */
        if (name.text == nil) {
            
            // Initiating name field from Facebook userName
            if let identityUserName = identityManager.userName {
            dbName=identityUserName
            name.text = identityUserName
            } else {
            name.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
            }
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
        
        
        // Function to disable keyboard upon touching anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Function to disable keyboard (called in viewDidLoad())
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    /* Next four functions are for adjusting of textfield when keyboard shows up */
    @IBOutlet weak var scrollView: UIScrollView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let screenHeight = UIScreen.main.bounds.height
        scrollView.setContentOffset(CGPoint(x:0, y:(750 - screenHeight+textField.frame.origin.y + textField.frame.height)), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
}
