//
//  ViewController.swift
//  WelcomePageTest
//
//  Created by ZuYuan Fan on 4/1/17.
//  Copyright © 2017 Ryan Fan. All rights reserved.
//

import UIKit
import LTMorphingLabel
import TextFieldEffects
import NVActivityIndicatorView
import AWSMobileHubHelper
import AWSS3
import FBSDKCoreKit

class FirstTimeUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var currentPage = 0
    // Page 1
    var welcomeLabel1 = LTMorphingLabel()
    let welcomeLabel2 = UILabel()
    let welcomeButton = UIButton()
    
    // Page 2
    let secondPageLabel = UILabel()
    let nameTextField = HoshiTextField()
    let emailTextField = HoshiTextField()
    let ageTextField = HoshiTextField()
    let genderTextField = HoshiTextField()
    let regionTextField = HoshiTextField()
    let basicInfoButton = UIButton()
    
    let genderPicker = UIPickerView()
    let genderOption = ["Male", "Female", "Other"]
    
    // Page 2 warning label
    let emptyWarningLabel = UILabel()
    let emptyWarningLabel2 = UILabel()
    
    // Back button
    let backButton = UIButton()
    
    // Page 3
    let thirdPageLabel = UILabel()
    let bioTextField = HoshiTextField()
    
    // Page 4
    let profilePicPageLabel = UILabel()
    let profilePicView = UIImageView()
    let profilePicUploadButton = UIButton(type: .system)
    var isGoPopUp: Bool = false
    var uploadFileURL: NSURL?
    var uploadingFileURL: URL?
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
    var blurEffectView: UIVisualEffectView?
    let loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 30, y: UIScreen.main.bounds.height/2 - 30, width: 60, height: 60), type: .ballRotateChase, color: UIColor.darkGray, padding: CGFloat(0))
    
    // Page 5
    var endingText = LTMorphingLabel()
    let endingButton = UIButton()
    let endingText2 = UILabel()
    
    // Last Page
    let goAppButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        if (!isGoPopUp) {
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.addSubview(self.welcomeLabel1)
                self.view.addSubview(self.welcomeLabel2)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 1, options: .curveEaseOut, animations: {
                    self.welcomeLabel2.alpha = 1
                }, completion: { _ in
                    self.view.addSubview(self.welcomeButton)
                    UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseOut, animations: {
                        self.welcomeButton.alpha = 1
                    }, completion: nil)
                })
            })
        }
        else {
            isGoPopUp = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        currentPage = 1
        // ============================================================
        // Page 1
        // No 1
        welcomeLabel1.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 50)
        welcomeLabel1.textAlignment = .center
        welcomeLabel1.font = UIFont(name: "Comfortaa-Regular", size: 35)
        welcomeLabel1.text = "Welcome!"
        welcomeLabel1.morphingEffect = .scale
        welcomeLabel1.morphingDuration = 1
        
        // No 2
        welcomeLabel2.font = UIFont(name: "Raleway-Light", size: 15)
        welcomeLabel2.text = "Before we start, meetzam want to inquire some basic information from you"
        welcomeLabel2.frame = CGRect(x: 30, y: UIScreen.main.bounds.height - 280, width: UIScreen.main.bounds.width - 60, height: 100)
        welcomeLabel2.lineBreakMode = .byTruncatingTail;
        welcomeLabel2.numberOfLines = 2;
        welcomeLabel2.textAlignment = .center
        welcomeLabel2.alpha = 0
        
        // No 3
        welcomeButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width, height: 50)
        welcomeButton.backgroundColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        if let font = UIFont(name: "Comfortaa-Regular", size: 15) {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let myString = "GET STARTED"
            let myAttribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: style]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            welcomeButton.setAttributedTitle(myAttrString, for: .normal)
        }
        else {
            welcomeButton.setTitle("Get Started", for: .normal)
        }
        welcomeButton.addTarget(self, action: #selector(welcomeButtonAction), for: .touchUpInside)
        welcomeButton.alpha = 0
        
        // ============================================================
        // Page 2
        self.hideKeyboard()
        
        // No 0
        secondPageLabel.font = UIFont(name: "Raleway-Light", size: 30)
        secondPageLabel.text = "Basic Information: "
        secondPageLabel.frame = CGRect(x: 30, y: 100, width: UIScreen.main.bounds.width, height: 50)
        secondPageLabel.textAlignment = .left
        secondPageLabel.alpha = 0
        
        // No 1
        nameTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 200, width: UIScreen.main.bounds.width * 0.7, height: 50)
        nameTextField.placeholderColor = .gray
        nameTextField.placeholder = "Display Name *"
        nameTextField.borderInactiveColor = UIColor.darkGray
        nameTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        nameTextField.font = UIFont(name: "Raleway-Light", size: 18)
        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no
        nameTextField.alpha = 0
        nameTextField.delegate = self
        nameTextField.tag = 0
        
        // No 2
        emailTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 250 + 5, width: UIScreen.main.bounds.width * 0.7, height: 50)
        emailTextField.placeholderColor = .gray
        emailTextField.placeholder = "Email *"
        emailTextField.borderInactiveColor = UIColor.darkGray
        emailTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        emailTextField.font = UIFont(name: "Raleway-Light", size: 18)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.alpha = 0
        emailTextField.delegate = self
        emailTextField.tag = 1
        
        // No 3
        ageTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 305 + 5, width: UIScreen.main.bounds.width * 0.7, height: 50)
        ageTextField.placeholderColor = .gray
        ageTextField.placeholder = "Age"
        ageTextField.borderInactiveColor = UIColor.darkGray
        ageTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        ageTextField.font = UIFont(name: "Raleway-Light", size: 18)
        ageTextField.keyboardType = .asciiCapableNumberPad
        ageTextField.alpha = 0
        ageTextField.delegate = self
        ageTextField.tag = 2
        
        // No 4
        genderTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 360 + 5, width: UIScreen.main.bounds.width * 0.7, height: 50)
        genderTextField.placeholderColor = .gray
        genderTextField.placeholder = "Gender"
        genderTextField.borderInactiveColor = UIColor.darkGray
        genderTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        genderTextField.font = UIFont(name: "Raleway-Light", size: 18)
        genderTextField.alpha = 0
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
        genderTextField.delegate = self
        genderTextField.tag = 3
        
        // No 5
        regionTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 415 + 5, width: UIScreen.main.bounds.width * 0.7, height: 50)
        regionTextField.placeholderColor = .gray
        regionTextField.placeholder = "Region"
        regionTextField.borderInactiveColor = UIColor.darkGray
        regionTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        regionTextField.font = UIFont(name: "Raleway-Light", size: 18)
        regionTextField.autocapitalizationType = .words
        regionTextField.alpha = 0
        regionTextField.delegate = self
        regionTextField.tag = 4
        
        // No 6
        basicInfoButton.frame = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width/2, height: 50)
        basicInfoButton.backgroundColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        if let font = UIFont(name: "Comfortaa-Regular", size: 15) {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let myString = "NEXT"
            let myAttribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: style]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            basicInfoButton.setAttributedTitle(myAttrString, for: .normal)
            basicInfoButton.contentVerticalAlignment = .center
        }
        else {
            basicInfoButton.setTitle("Next", for: .normal)
        }
        basicInfoButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
        basicInfoButton.alpha = 0
        
        // No 7
        backButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width/2, height: 50)
        backButton.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.8)
        if let font = UIFont(name: "Comfortaa-Regular", size: 15) {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let myString = "BACK"
            let myAttribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: style]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            backButton.setAttributedTitle(myAttrString, for: .normal)
            backButton.contentVerticalAlignment = .center
        }
        else {
            backButton.setTitle("Back", for: .normal)
        }
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.alpha = 0
        
        // Warning label
        emptyWarningLabel.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 250, width: UIScreen.main.bounds.width * 0.7, height: 12)
        emptyWarningLabel.text = "You can't leave this empty."
        emptyWarningLabel.textAlignment = .right
        emptyWarningLabel.textColor = UIColor.red
        emptyWarningLabel.font = UIFont(name: "Raleway-Light", size: 10)
        emptyWarningLabel.alpha = 0
        
        // Warning label2
        emptyWarningLabel2.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 305, width: UIScreen.main.bounds.width * 0.7, height: 12)
        emptyWarningLabel2.text = "You can't leave this empty."
        emptyWarningLabel2.textAlignment = .right
        emptyWarningLabel2.textColor = UIColor.red
        emptyWarningLabel2.font = UIFont(name: "Raleway-Light", size: 10)
        emptyWarningLabel2.alpha = 0
        // ============================================================
        // Page 3
        // No 0
        thirdPageLabel.font = UIFont(name: "Raleway-Light", size: 30)
        thirdPageLabel.text = "Introduce Yourself: "
        thirdPageLabel.frame = CGRect(x: 30, y: 100, width: UIScreen.main.bounds.width, height: 50)
        thirdPageLabel.textAlignment = .left
        thirdPageLabel.alpha = 0
        
        // No 1
        bioTextField.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: UIScreen.main.bounds.height/2 - 100, width: UIScreen.main.bounds.width * 0.7, height: 50)
        bioTextField.placeholderColor = .gray
        bioTextField.placeholder = "Bio"
        bioTextField.borderInactiveColor = UIColor.darkGray
        bioTextField.borderActiveColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        bioTextField.font = UIFont(name: "Raleway-Light", size: 18)
        bioTextField.autocapitalizationType = .sentences
        bioTextField.alpha = 0
        bioTextField.delegate = self
        // ============================================================
        // Page 4
        // No 0
        profilePicPageLabel.font = UIFont(name: "Raleway-Light", size: 30)
        profilePicPageLabel.text = "Upload Profile Picture: "
        profilePicPageLabel.frame = CGRect(x: 30, y: 100, width: UIScreen.main.bounds.width, height: 50)
        profilePicPageLabel.textAlignment = .left
        profilePicPageLabel.alpha = 0
        
        // No 1
        profilePicView.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: 200, width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.7)
        profilePicView.image = UIImage(named: "defaultProfilePic")
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.alpha = 0
        
        // No 2
        let new_y = 200 + (UIScreen.main.bounds.width * 0.7) + 20
        profilePicUploadButton.frame = CGRect(x: UIScreen.main.bounds.width * 0.15, y: new_y, width: UIScreen.main.bounds.width * 0.7, height: 50)
        profilePicUploadButton.setTitle("Change Profile Photo", for: .normal)
        profilePicUploadButton.addTarget(self, action: #selector(uploadPicButtonAction), for: .touchUpInside)
        profilePicUploadButton.alpha = 0
        
        // ============================================================
        // Last Page
        // No 2
        endingText2.font = UIFont(name: "Raleway-Light", size: 15)
        endingText2.text = "Your information looks good \n\n\n Now please enjoy the app!"
        endingText2.frame = CGRect(x: 30, y: UIScreen.main.bounds.height - 280, width: UIScreen.main.bounds.width - 60, height: 100)
        endingText2.lineBreakMode = .byTruncatingTail;
        endingText2.numberOfLines = 4;
        endingText2.textAlignment = .center
        endingText2.alpha = 0
        
        // No 3
        goAppButton.frame = CGRect(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.8, width: UIScreen.main.bounds.width * 0.6, height: 50)
        goAppButton.backgroundColor = UIColor.init(red: 242/255, green: 92/255, blue: 0/255, alpha: 0.8)
        goAppButton.addTarget(self, action: #selector(goAppButtonAction), for: .touchUpInside)
        if let font = UIFont(name: "Comfortaa-Regular", size: 17) {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let myString = "meetzam"
            let myAttribute = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: style]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            goAppButton.setAttributedTitle(myAttrString, for: .normal)
            goAppButton.contentVerticalAlignment = .center
        }
        goAppButton.alpha = 0
    }
    
    // Welcome button action
    func welcomeButtonAction(sender: UIButton!) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        })
        
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.welcomeLabel1.alpha = 0
            self.welcomeLabel2.alpha = 0
            self.welcomeButton.alpha = 0
        }, completion: {(finished: Bool) in
            self.welcomeLabel1.removeFromSuperview()
            self.welcomeLabel2.removeFromSuperview()
            self.welcomeButton.removeFromSuperview()
            
            // Second Page
            self.view.addSubview(self.secondPageLabel)
            self.secondPageLabel.alpha = 1
            self.view.addSubview(self.nameTextField)
            self.nameTextField.alpha = 1
            self.view.addSubview(self.emailTextField)
            self.emailTextField.alpha = 1
            self.view.addSubview(self.ageTextField)
            self.ageTextField.alpha = 1
            self.view.addSubview(self.genderTextField)
            self.genderTextField.alpha = 1
            self.view.addSubview(self.regionTextField)
            self.regionTextField.alpha = 1
            self.view.addSubview(self.basicInfoButton)
            self.basicInfoButton.alpha = 1
            self.backButton.alpha = 1
            self.view.addSubview(self.backButton)
            
            self.currentPage = 2
        })
    }
    
    // Submit button action
    func submitButtonAction(sender: UIButton!) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        })
        
        // current page is 2
        if (self.currentPage == 2) {
            // check the strings
            var isempty = false
            if (nameTextField.text == "") {
                isempty = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.nameTextField.placeholderColor = UIColor.red
                    self.nameTextField.borderInactiveColor = UIColor.red
                    
                    self.emptyWarningLabel.alpha = 1
                    self.view.addSubview(self.emptyWarningLabel)
                    
                }, completion: nil)
            }
            else {
                isempty = false
                self.emptyWarningLabel.alpha = 0
                self.emptyWarningLabel.removeFromSuperview()
            }
            
            if (emailTextField.text == "") {
                isempty = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.emailTextField.placeholderColor = UIColor.red
                    self.emailTextField.borderInactiveColor = UIColor.red
                    
                    self.emptyWarningLabel2.alpha = 1
                    self.view.addSubview(self.emptyWarningLabel2)
                }, completion: nil)
            }
            else {
                isempty = false
                self.emptyWarningLabel2.alpha = 0
                self.emptyWarningLabel2.removeFromSuperview()
            }
            
            if (isempty == false) {
                self.nameTextField.placeholderColor = .gray
                self.nameTextField.borderInactiveColor = UIColor.darkGray
                self.emailTextField.placeholderColor = .gray
                self.emailTextField.borderInactiveColor = UIColor.darkGray
                self.ageTextField.borderInactiveColor = UIColor.darkGray
                self.genderTextField.borderInactiveColor = UIColor.darkGray
                self.regionTextField.borderInactiveColor = UIColor.darkGray
                
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.secondPageLabel.alpha = 0
                    self.nameTextField.alpha = 0
                    self.emailTextField.alpha = 0
                    self.ageTextField.alpha = 0
                    self.genderTextField.alpha = 0
                    self.regionTextField.alpha = 0
                    
                }, completion: {(finished: Bool) in
                    self.view.addSubview(self.thirdPageLabel)
                    self.thirdPageLabel.alpha = 1
                    self.view.addSubview(self.bioTextField)
                    self.bioTextField.alpha = 1
                    
                    self.currentPage = 3
                })
            }
        }
            
        // current page is 3
        else if (self.currentPage == 3) {
            self.regionTextField.borderInactiveColor = UIColor.darkGray
            
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.thirdPageLabel.alpha = 0
                self.bioTextField.alpha = 0
                
            }, completion: {(finished: Bool) in
                self.view.addSubview(self.profilePicPageLabel)
                self.profilePicPageLabel.alpha = 1
                self.view.addSubview(self.profilePicView)
                self.profilePicView.alpha = 1
                self.view.addSubview(self.profilePicUploadButton)
                self.profilePicUploadButton.alpha = 1
                
                self.currentPage = 4
            })
        }
    
        // current page is 4
        else if (self.currentPage == 4) {
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = UIScreen.main.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView?.alpha = 0
            self.view.addSubview(blurEffectView!)
            
            loadingIndicator.startAnimating()
            self.view.window!.addSubview(loadingIndicator)
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.blurEffectView!.alpha = 0.98
                
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.basicInfoButton.alpha = 0
                    self.backButton.alpha = 0
                    self.profilePicPageLabel.alpha = 0
                    self.profilePicView.alpha = 0
                    self.profilePicUploadButton.alpha = 0
                    
                }, completion: {(finished: Bool) in
                    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    // Send the profiles to DB
                    let myId = AWSIdentityManager.default().identityId!
                    var name = self.nameTextField.text
                    var bio = self.bioTextField.text
                    var age = self.ageTextField.text
                    var gender = self.genderTextField.text
                    var region = self.regionTextField.text
                    var email = self.emailTextField.text
                    
                    // check nil string
                    if name == "" {
                        name = "Unknown Name"
                    }
                    if bio == "" {
                        bio = "Unknown Bio"
                    }
                    if age == "" {
                        age = "Unknown Age"
                    }
                    if gender == "" {
                        gender = "Unknown Gender"
                    }
                    if region == "" {
                        region = "Unknown Region"
                    }
                    if email == "" {
                        email = "Unknown Email"
                    }
                    
                    UserProfileToDB().insertProfile(_userId: myId, _displayName: name!, _bio: bio!, _age: age!, _gender: gender!, _region: region!, _email: email!)
                    
                    // create a temp pic
                    if self.profilePicView.image == #imageLiteral(resourceName: "defaultProfilePic") {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        if let image = self.profilePicView.image {
                            let fileURL = documentsURL.appendingPathComponent("ryan19.jpg")
                            if let jpgImageData = UIImageJPEGRepresentation(image, 1) {
                                do {
                                    try jpgImageData.write(to: fileURL)
                                    self.uploadFileURL = fileURL as NSURL
                                    
                                } catch let err {
                                    print(err)
                                }
                            }
                        }
                        
                    }
                    //getting details of image
                    let imageName = self.uploadFileURL?.lastPathComponent
                    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String

                    // getting local path
                    let localPath = (documentDirectory as NSString).appendingPathComponent(imageName!)
                    self.uploadingFileURL = URL(fileURLWithPath: localPath)
                    
                    //getting actual image
                    if let safe_image = self.profilePicView.image {
                        let data = UIImageJPEGRepresentation(safe_image, 0)
                        do {
                            try data?.write(to: self.uploadingFileURL!)
                            
                        } catch let err {
                            print(err)
                        }
                    }

                    self.uploadProfileImage()
                    
                    // delete the temp pic
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent("ryan19.jpg")
                    if (fileManager.fileExists(atPath: fileURL.path)) {
                        do {
                            try fileManager.removeItem(atPath: fileURL.path)
                        } catch let error {
                            print("Ooops! Something went wrong: \(error)")
                        }
                    }
                    else {
                        print("ryan19.jpg not found")
                    }
                    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    
                    // Page 2+3+4
                    self.secondPageLabel.removeFromSuperview()
                    self.nameTextField.removeFromSuperview()
                    self.emailTextField.removeFromSuperview()
                    self.ageTextField.removeFromSuperview()
                    self.genderTextField.removeFromSuperview()
                    self.regionTextField.removeFromSuperview()
                    self.basicInfoButton.removeFromSuperview()
                    self.backButton.removeFromSuperview()
                    self.genderPicker.removeFromSuperview()
                    self.bioTextField.removeFromSuperview()
                    self.thirdPageLabel.removeFromSuperview()
                    self.profilePicPageLabel.removeFromSuperview()
                    self.profilePicView.removeFromSuperview()
                    self.profilePicUploadButton.removeFromSuperview()
    
                    // Page 5
                    // No 1
                    self.endingText = LTMorphingLabel()
                    self.endingText.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 50)
                    self.endingText.textAlignment = .center
                    self.endingText.font = UIFont(name: "Comfortaa-Regular", size: 35)
                    self.endingText.text = "Congratulations!"
                    self.endingText.morphingEffect = .scale
                    self.endingText.morphingDuration = 1
                    self.view.addSubview(self.endingText)
                    
                    self.view.addSubview(self.endingText2)
                    UIView.animate(withDuration: 0.2, delay: 1, options: .curveEaseOut, animations: {
                        self.endingText2.alpha = 1
                    }, completion: nil)
                    
                    self.view.addSubview(self.goAppButton)
                    UIView.animate(withDuration: 0.2, delay: 1.5, options: .curveEaseOut, animations: {
                        self.goAppButton.alpha = 1
                    }, completion: nil)
    
                    self.currentPage = -1
                })

            })
            
        }
        
    }
    
    // Back button action
    func backButtonAction(sender: UIButton!) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        })
        
        if (self.currentPage == 2) {
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.secondPageLabel.alpha = 0
                self.nameTextField.alpha = 0
                self.emailTextField.alpha = 0
                self.ageTextField.alpha = 0
                self.genderTextField.alpha = 0
                self.regionTextField.alpha = 0
                self.basicInfoButton.alpha = 0
                self.backButton.alpha = 0
            }, completion: {(finished: Bool) in
                self.secondPageLabel.removeFromSuperview()
                self.nameTextField.removeFromSuperview()
                self.emailTextField.removeFromSuperview()
                self.ageTextField.removeFromSuperview()
                self.genderTextField.removeFromSuperview()
                self.regionTextField.removeFromSuperview()
                self.basicInfoButton.removeFromSuperview()
                self.backButton.removeFromSuperview()
                self.genderPicker.removeFromSuperview()
                
                self.welcomeLabel1 = LTMorphingLabel()
                
                self.viewWillAppear(false)
                self.viewDidLoad()
                
            })
        }
        else if (self.currentPage == 3) {
            self.bioTextField.borderInactiveColor = UIColor.darkGray
            
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                // Thrid Page
                self.thirdPageLabel.alpha = 0
                self.bioTextField.alpha = 0
            }, completion: {(finished: Bool) in
                // Second Page
                self.secondPageLabel.alpha = 1
                self.nameTextField.alpha = 1
                self.emailTextField.alpha = 1
                self.ageTextField.alpha = 1
                self.genderTextField.alpha = 1
                self.regionTextField.alpha = 1
                self.basicInfoButton.alpha = 1
                self.backButton.alpha = 1
                
                self.currentPage = 2
            })
        }
        
        else if (self.currentPage == 4) {
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                // Fourth page
                self.profilePicPageLabel.alpha = 0
                self.profilePicView.alpha = 0
                self.profilePicUploadButton.alpha = 0
                
                
            }, completion: {(finished: Bool) in
                // Thrid Page
                self.thirdPageLabel.alpha = 1
                self.bioTextField.alpha = 1
                
                self.currentPage = 3
            })

        }
        
    }
    
    // Go app button action
    func goAppButtonAction(sender: UIButton!) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.frame = CGRect(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height/2 - 25, width: UIScreen.main.bounds.width * 0.6, height: 50)
            sender.setAttributedTitle(nil, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                sender.frame = CGRect(x: UIScreen.main.bounds.width/2 - 25, y: UIScreen.main.bounds.height/2 - 25, width: 50*(UIScreen.main.bounds.width/UIScreen.main.bounds.height), height: 50)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    self.endingText.alpha = 0
                    self.endingText2.alpha = 0
                    sender.transform = CGAffineTransform(scaleX: 30, y: 30)
                }, completion: { _ in
                    self.endingText.removeFromSuperview()
                    self.endingText2.removeFromSuperview()
                    let endendText = UILabel()
                    endendText.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-100, width: UIScreen.main.bounds.width, height: 50)
                    endendText.text = "© 2017 meetzam-dev"
                    endendText.font = UIFont(name: "Comfortaa-Regular", size: 20)
                    endendText.textAlignment = .center
                    endendText.textColor = UIColor.white
                    endendText.alpha = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        endendText.alpha = 1
                        self.view.addSubview(endendText)
                    }, completion: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            let transition: CATransition = CATransition()
                            transition.duration = 0.3
                            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition.type = kCATransitionReveal
                            transition.subtype = kCATransitionFade
                            self.view.window!.layer.add(transition, forKey: nil)
                            
                            self.dismiss(animated: false, completion: nil)
                            
                        })
                        
                    })
                })
            })
        })
    }
    
    // Upload profile pic button action
    func uploadPicButtonAction(sender: UIButton!) {
        let popUpMenu = UIAlertController.init(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let albumAction = UIAlertAction.init(title: "Choose from Library", style: .default, handler: libraryHandler)
        let fbAction = UIAlertAction.init(title: "Use Facebook Profile Picture", style: .default, handler: fbHandler)
        
        popUpMenu.addAction(albumAction)
        popUpMenu.addAction(fbAction)
        popUpMenu.addAction(cancelAction)
        
        self.present(popUpMenu, animated: true, completion: nil)
        
    }
    
    // Choose from library action
    func libraryHandler(alert: UIAlertAction!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        isGoPopUp = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Choose facebook profile picture
    func fbHandler(alert: UIAlertAction!) {
        var largeImageURL = ""
        let fbid = FBSDKAccessToken.current().userID
        if (fbid != nil) {
            largeImageURL = "https://graph.facebook.com/" + fbid! + "/picture?type=large&redirect=true&width=720&height=720"
            if let imageURL = URL(string: largeImageURL) {
                let imageData = try! Data(contentsOf: imageURL)
                if let profileImage = UIImage(data: imageData) {
                    self.profilePicView.image = profileImage
                    // create a temp pic
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    if let image = self.profilePicView.image {
                        let fileURL = documentsURL.appendingPathComponent("ryan19.jpg")
                        if let jpgImageData = UIImageJPEGRepresentation(image, 1) {
                            do {
                                try jpgImageData.write(to: fileURL)
                                self.uploadFileURL = fileURL as NSURL
                                
                            } catch let err {
                                print(err)
                            }
                        }
                    }
                    // create a temp pic
                }
            }
        }
        
    }
    
    // after finish picking photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let ogImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicView.image = ogImage
            
            self.uploadFileURL = info[UIImagePickerControllerReferenceURL] as? NSURL
            
        }
        else {
            print("error picking image")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Gender Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOption.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderOption[row]
    }
    
    // Keyboard popup adjust screen
    func animateTextField(textField: UITextField, up: Bool) {
        let movementDistance:CGFloat = -100
        let movementDuration: Double = 0.17
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        }
        else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
        if (textField.placeholder == "Gender") {
            if (genderTextField.text == "") {
                genderTextField.text = genderOption[0]
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // mush S3 funciton
    func uploadProfileImage() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("===== uploadProfileImage =====")
        var waiting = 0
        var dummy = 0
        let transferManager = AWSS3TransferManager.default()
        //let testFileURL1 = uploadingFileURL
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest1.bucket = "testprofile-meetzam"
        uploadRequest1.key =  AWSIdentityManager.default().identityId! + ".jpeg"
        uploadRequest1.body = uploadingFileURL!
        transferManager.upload(uploadRequest1).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Upload Error: \(error)")
            }
            else {
                print("SUCCESS")
            }
            dummy = 6
            return nil
        }).waitUntilFinished()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.blurEffectView?.alpha = 0
            self.loadingIndicator.stopAnimating()
        }, completion: { _ in
            self.blurEffectView?.removeFromSuperview()
            self.loadingIndicator.removeFromSuperview()
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
