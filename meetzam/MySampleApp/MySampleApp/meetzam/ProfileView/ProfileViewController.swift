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
    
    //declare AWS DB var
    var user_profile: UserProfileToDB?
    
    //************************** VIEW DID LOAD ********************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserProfileToDB().getProfileForDisplay(key: AWSIdentityManager.default().identityId!, user_profile: user_profile, displayname: displayName, bio: userBioField)
        
        //======================== formatting background==========================\\
        self.view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        self.mainScrollView.backgroundColor = UIColor.clear
        self.profileMainBodyView.backgroundColor = UIColor.clear
        
        //=========================call AWS identity manager==========================\\
        let identityManager = AWSIdentityManager.default()
        AWSIdentityManager.default()
        
        //=========================set size and location of NAME Label==========================\\
        // new frame:
        displayName.frame = CGRect(x: 0, y: userPicField.frame.height + 30, width: UIScreen.main.bounds.width, height: 50)
        displayName.font = UIFont(name: "HelveticaNeue-Light", size: 23)
        //UIFont(name: "HelveticaNeue-Light", size: 23)
        
        /* when the user first log in to meetzam, get name from database */
        if (displayName.text == nil) {
            if let identityUserName = identityManager.userName {
                displayName.text = identityUserName
            } else {
                displayName.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
            }
        }
        
        // new center:
        displayName.textAlignment = .center
        self.profileMainBodyView.addSubview(displayName)
        
        //======set size and location of BIO Label=======\\
        // new frame:
        userBioField.frame = CGRect(x: 0, y: userPicField.frame.height + 60, width: UIScreen.main.bounds.width, height: 50)
        userBioField.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        
        // new center:
        userBioField.textAlignment = .center
        
        // if this user's profile is empty, set teh default bio
        if (userBioField.text != nil) {
            userBioField.text = "(System) Add your first Bio!"
            //userBioField.textColor = UIColor.lightGray
        }
        
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
        TopThreeMovieCollectionView.backgroundColor = UIColor.clear
        
    }
  
    //********************* VIEW DID APPEAR ***********************************************//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /* get name and bio from database */
        UserProfileToDB().getProfileForDisplay(key: AWSIdentityManager.default().identityId!, user_profile: user_profile, displayname: displayName, bio: userBioField)
        
        /* format name and bio */
        displayName.textAlignment = .center
        userBioField.textAlignment = .center
        
        self.profileMainBodyView.addSubview(displayName)
        self.profileMainBodyView.addSubview(userBioField)
        
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
