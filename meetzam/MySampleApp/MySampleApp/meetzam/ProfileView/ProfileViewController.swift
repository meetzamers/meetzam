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

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var TopThreeMovieCollectionView: UICollectionView!
    @IBOutlet weak var profileMainBodyView: UIView!
    
    
    var topThreeImages = ["split","loganposter2","lala"]
    
    //declare profile picture field
    let userPicField = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width*0.15, y: 30, width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.width*0.7))
    
    //declare displayName
    let displayName = UILabel()
    
    //declare bio
    let userBioField = UILabel()
    
    var user_profile: UserProfileToDB?
    
    
//************************** VIEW DID LOAD ********************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserProfileToDB().getProfileForDisplay(key: AWSIdentityManager.default().identityId!, user_profile: user_profile, displayname: displayName, bio: userBioField)
        
    //======================== formatting background==========================\\
        self.view.backgroundColor = UIColor.init(red:242/255, green: 242/255, blue: 242/255, alpha: 1)
        self.mainScrollView.backgroundColor = UIColor.init(red:242/255, green: 242/255, blue: 242/255, alpha: 1)
        self.profileMainBodyView.backgroundColor = UIColor.init(red:242/255, green: 242/255, blue: 242/255, alpha: 1)
        
    //=========================set size and location of NAME Label==========================\\
        displayName.frame = CGRect(x: 50, y: userPicField.frame.height + 40, width: 200, height: 50)
        displayName.font = UIFont(name:"Helvetica", size: 23)
        
        let identityManager = AWSIdentityManager.default()
        AWSIdentityManager.default()
        
        /* when the user first log in to meetzam, get name from database */
        if (displayName.text == nil) {
            if let identityUserName = identityManager.userName {
                displayName.text = identityUserName
            } else {
                displayName.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
            }
        }
        
        displayName.sizeToFit()
        displayName.center = CGPoint(x: UIScreen.main.bounds.width/2, y: userPicField.frame.height + 50)
        self.profileMainBodyView.addSubview(displayName)
        
    //======set size and location of BIO Label=======\\
        userBioField.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        
        userBioField.font = UIFont(name:"Helvetica", size: 18)
        if (userBioField.text != nil){
            userBioField.sizeToFit()
        }
        userBioField.center = CGPoint(x: UIScreen.main.bounds.width/2, y:userPicField.frame.height + 80)
        self.profileMainBodyView.addSubview(userBioField)

        
        
    //============set Profile Picture ==============\\
        self.profileMainBodyView.addSubview(userPicField)
        if let imageURL = identityManager.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                userPicField.image = profileImage
            } else {
                userPicField.image = UIImage(named: "UserIcon")
            }
        }
  
        //show top three movies
        TopThreeMovieCollectionView.delegate = self;
        TopThreeMovieCollectionView.dataSource = self;
        
    }
  
//********************* VIEW DID APPEAR ***********************************************//
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* get name and bio from database */
        UserProfileToDB().getProfileForDisplay(key: AWSIdentityManager.default().identityId!, user_profile: user_profile, displayname: displayName, bio: userBioField)
        
        /* format name and bio */
        displayName.sizeToFit()
        displayName.center = CGPoint(x: UIScreen.main.bounds.width/2, y: userPicField.frame.height + 50)
        
        userBioField.sizeToFit()
        userBioField.center = CGPoint(x: UIScreen.main.bounds.width/2, y:userPicField.frame.height + 80)

    }
    
    
    
    
    
    // Go to all movies I liked
    @IBAction func toLikedMovies(_ sender: Any) {
        self.performSegue(withIdentifier: "toMovies", sender: self)
    }
    
    // Go to setting page
    @IBAction func toSettingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSetSegue", sender: self)
    }
    

    @IBAction func toEditProfileButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toEditProfile", sender: self)
    }

    

    //setting up top three movie collection view
    //conform with UICollectionView protocal
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topThreeImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = TopThreeMovieCollectionView.dequeueReusableCell(withReuseIdentifier: "topThreeCell", for: indexPath) as! TopThreeMovieCell
        
        cell.Top3MovieImage.image = UIImage(named: topThreeImages[indexPath.row])
        return cell
    }
    
    
    
    

}
