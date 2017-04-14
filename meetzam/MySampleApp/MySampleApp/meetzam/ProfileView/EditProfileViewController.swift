//
//  EditProfileViewController.swift
//  MySampleApp
//
//  Created by Sean Chew on 2/22/17.
//  mushroom: upload profile photo 3/25/2017
//           ____
//       _.-'78o `"`--._
//   ,o888o.  .o888o,   ''-.
// ,88888P  `78888P..______.]
///_..__..----""        __.'
//`-._       /""| _..-''
//    "`-----\  `\
//            |   ;.-""--..
//            | ,8o.  o88. `.
//            `;888P  `788P  :
//      .o""-.|`-._         ./
//     J88 _.-/    ";"-P----'
//     `--'\`|     /  /
//         | /     |  |
//         \|     /   |akn
//          `-----`---'
//
//  profile photo需要一定时间上传，返回profile page之后图片的更新不能通过下载s3.
//  另外，选择头像时候可以resize， 可是传上s3的图片是原图。 
//  要么就在取图片resize之后看看能不能有个temp的新的图片，要么干脆没有resize功能好了
//  上载图片如果有预先压缩功能就好了，要不然真的慢
//      更新：预压缩成jpeg最差质量，对于头像够了
//          因为压缩了，时间短了，可以等下载完了再返回profile页面然后现实更新的。
//          但是我实在不知道怎么等到下载完。
//  
//  更新：
    /*
    downloadProfileImage()
 
    if (downloadingFileURL == nil) {
         // user has not uploaded a profile photo
         // either he/she use default facebook photo
         // or he/she deleted profiel photo
        //handling
    }
    */
//  现在我还不知道download应该放在哪里。 现在upload完直接download。
//
//  存的地方会不会变我也不知道哈哈，估计在viewdidload里面需要download。
//

import UIKit
import Foundation
import AWSS3
import AWSMobileHubHelper
import FBSDKCoreKit

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
    //mush (for s3)
    var uploadingFileURL: URL?
    var downloadingFileURL: URL?
    
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
            //getting details of image
            let uploadFileURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        
            let imageName = uploadFileURL.lastPathComponent
 
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
 
            // getting local path
            let localPath = (documentDirectory as NSString).appendingPathComponent(imageName!)
            uploadingFileURL = URL(fileURLWithPath: localPath)
        
            //getting actual image
            //let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let data = UIImageJPEGRepresentation(image, 0)
            try! data?.write(to: uploadingFileURL!)
        } else {
            // Error message
            print("get image error")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //mush
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
            } else {
                print("SUCCESS")
                
               
            }
            dummy = 6
            return nil
        })
        while (dummy != 6) {
            waiting = 1
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        
    }
    
    func downloadProfileImage() {
        print("===== downloadProfileImage =====")
        
        let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp-download")
        self.downloadingFileURL = NSURL(fileURLWithPath: downloadingFilePath1 ) as URL!
        
        let transferManager = AWSS3TransferManager.default()
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = "testprofile-meetzam"
        readRequest1.key =  AWSIdentityManager.default().identityId! + ".jpeg"
        readRequest1.downloadingFileURL = downloadingFileURL
        transferManager.download(readRequest1).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("download Error: \(error)")
                self.downloadingFileURL = nil
            } else {
                print("download Successful")
                //monika
                if (self.downloadingFileURL != nil) {
                    let imageURL = URL(fileURLWithPath: (self.downloadingFileURL?.path)!)
                    let image    = UIImage(contentsOfFile: imageURL.path)
                        
                    if (image == nil) {
                        print("cannot get the image")
                    } else {
                        self.profilePicture.image = image
                    }
                }
                //monika
            }
            return nil
        })
    }
    
    func deleteProfileImage() {
        print("===== deleteProfileImage =====")
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = "testprofile-meetzam"
        deleteObjectRequest?.key = AWSIdentityManager.default().identityId! + ".jpeg"
        s3.deleteObject(deleteObjectRequest!).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            else {
                print("SUCCESS")
            }
            return nil
        })
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
        
        if (uploadingFileURL != nil) {
            print("prepare uploading")
            uploadProfileImage()
        }
        /*
        print("get arn")
        let arn = UserProfileToDB().getDeviceArn(userID: dbID)
        print("device arn is \(arn ?? "no arn")")
        */
        //reset so that it will not upload pic too many times
        uploadingFileURL = nil
        //deleteProfileImage()
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
        downloadProfileImage()
        if (downloadingFileURL != nil) {
            /*
            if FileManager.default.fileExists(atPath: (downloadingFileURL?.path)!) {
                let url = NSURL(string: (downloadingFileURL?.path)!)
                let data = NSData(contentsOf: url! as URL)
                profilePicture.image = UIImage(data: data! as Data)
            }
            */
        } else {
        let fbid = FBSDKAccessToken.current().userID
        var largeImageURL = identityManager.imageURL?.absoluteString
        if (fbid != nil) {
            largeImageURL = "https://graph.facebook.com/" + fbid! + "/picture?type=large&redirect=true&width=720&height=720"
        }
        
        //if let imageURL = identityManager.imageURL {
        if let imageURL = URL(string: largeImageURL!) {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                profilePicture.image = profileImage
            } else {
                profilePicture.image = UIImage(named: "UserIcon")
            }
        }
        }
        
        // Function to disable keyboard upon touching anywhere else
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Function to disable keyboard (called in viewDidLoad())
    override func dismissKeyboard() {
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
