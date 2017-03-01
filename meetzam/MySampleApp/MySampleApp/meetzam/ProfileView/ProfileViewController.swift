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

    @IBOutlet weak var displayNameAndAgeField: UILabel!
    @IBOutlet weak var userBioField: UILabel!
    @IBOutlet weak var userPicField: UIImageView!
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get user name from facebook
        let identityManager = AWSIdentityManager.default()
        
        AWSIdentityManager.default()
        
        if let identityUserName = identityManager.userName {
            //if let identityAge = identityManager.
            
            displayNameAndAgeField.text = identityUserName
            
            //displayNameAndAgeField.text = identityUserName
        } else {
            displayNameAndAgeField.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        
        //mannually typed bio
        userBioField.text = "Hello! :)"
        
        
        //get user profile picture from facebook
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
    
    // Go to all movies I liked
    @IBAction func toAllMovies(_ sender: Any) {
        self.performSegue(withIdentifier: "toMovies", sender: self)
        
    }
    // Go to setting page
    @IBAction func toSettingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSetSegue", sender: self)
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
    
    
    var topThreeImages = ["split","loganposter2","lala"]
    
    
    @IBOutlet weak var TopThreeMovieCollectionView: UICollectionView!
    
    

}
