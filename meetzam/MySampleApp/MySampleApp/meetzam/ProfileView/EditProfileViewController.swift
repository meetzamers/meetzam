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

/*
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var currentImage: UIImageView!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this controller as the camera delegate
        imagePicker.delegate = self
    }
    
    // didFinishPickingMediaWithInfo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got an image")
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = Selector(("imageWasSavedSuccessfully:didFinishSavingWithError:context:"))
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an image
        })
    }
    
    // didUserCancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User cancelled image")
        dismiss(animated: true, completion: {
            
        })
    }
    
    // Make sure info was saved method
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!,
                                   context: UnsafeMutableRawPointer) {
        print("Image saved")
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            
        }
    }
    
    // takePicture function to take picture
    @IBAction func takePicture(sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if (UIImagePickerController.availableCaptureModes(for: .rear) != nil) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: {})
                
            } else {
                //postAlert("Rear Camera doesn't exist", message: "Application cannot access the camera.")
            }
            
        } else {
            //postAlert("Camera inaccesable", message: "Application cannot access the camera.")
        }
    }
}
 */

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    // Profile picture
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Image picker
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
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

    // These variables are for DATABASE storage
    var dbUserid: String!
    
    var dbName: String!
    
    var dbBio: String!
    
    var dbEmail: String!
    
    var dbAge: String!
    
    var dbGender: String!
    
    var dbRegion: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let identityManager = AWSIdentityManager.default()
        
        AWSIdentityManager.default()
        
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
    
        // Set this controller as the camera delegate
        imagePicker.delegate = self
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    //editing text
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

    
    
    
    
    
    
    
    
    // didFinishPickingMediaWithInfo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got an image")
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = Selector(("imageWasSavedSuccessfully:didFinishSavingWithError:context:"))
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an image
        })
    }
    
    // didUserCancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User cancelled image")
        dismiss(animated: true, completion: {
            
        })
    }
    
    // Make sure info was saved method
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!,
                                   context: UnsafeMutableRawPointer) {
        print("Image saved")
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            
        }
    }
    
    
    // Change profile picture button
    @IBAction func editProfilePictureButtonTapped(_ sender: UIButton) {
     
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if (UIImagePickerController.availableCaptureModes(for: .rear) != nil) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: {})
                
            } else {
                //postAlert("Rear Camera doesn't exist", message: "Application cannot access the camera.")
            }
            
        } else {
            //postAlert("Camera inaccesable", message: "Application cannot access the camera.")
        }
    }
    
    /*
    // takePicture function to take picture
    @IBAction func takePicture(sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if (UIImagePickerController.availableCaptureModes(for: .rear) != nil) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: {})
                
            } else {
                //postAlert("Rear Camera doesn't exist", message: "Application cannot access the camera.")
            }
            
        } else {
            //postAlert("Camera inaccesable", message: "Application cannot access the camera.")
        }
    }
    */

    
}
