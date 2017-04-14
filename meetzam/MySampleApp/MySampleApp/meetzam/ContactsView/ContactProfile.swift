//
//  ContactProfile.swift
//  MySampleApp
//
//  Created by 孟琦 on 4/14/17.
//
//

import UIKit

class ContactProfile: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //profile picture
        self.view.addSubview(userPicField)
        
        // user name
        displayName.frame = CGRect(x: 20, y: userPicField.frame.height + 5, width: UIScreen.main.bounds.width, height: 30)
        displayName.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        self.view.addSubview(displayName)
        
        // user bio
        userBioField.frame = CGRect(x: 20, y: userPicField.frame.height + 35, width: UIScreen.main.bounds.width, height: 20)
        userBioField.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        userBioField.textColor = UIColor.gray
        self.view.addSubview(userBioField)
        
        // also liked
        alsoLiked.text = "Liked"
        alsoLiked.frame = CGRect(x: 25, y: userPicField.frame.height + 70, width: UIScreen.main.bounds.width, height: 20)
        alsoLiked.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        alsoLiked.textColor = UIColor.darkGray
        self.view.addSubview(alsoLiked)
        
        
        // liked movie backgroundLabel
        backgroundLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.width + 70, width: UIScreen.main.bounds.width, height: 140)
        backgroundLabel.text = ""
        backgroundLabel.backgroundColor = UIColor.init(red: 173/255, green: 173/255, blue: 173/255, alpha: 1)
        self.view.addSubview(backgroundLabel)
        
        
        // movies
        moviePic1.frame = CGRect(x: 0, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width-30)/4, height: 140)
        moviePic2.contentMode = .scaleToFill
        
        moviePic2.frame = CGRect(x: moviePic1.frame.width, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width)/4, height: 140)
        
        moviePic3.frame = CGRect(x: moviePic1.frame.width*2, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width)/4, height: 140)
        
        moviePic4.frame = CGRect(x: moviePic1.frame.width*3, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width)/4, height: 140)
        
        
        self.view.addSubview(moviePic1)
        self.view.addSubview(moviePic2)
        self.view.addSubview(moviePic3)
        self.view.addSubview(moviePic4)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var userPicField = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
    
    let displayName = UILabel()
    
    let userBioField = UILabel()
    
    let alsoLiked = UILabel()
    
    let backgroundLabel = UILabel()
    
    var moviePic1 = UIImageView()
    
    var moviePic2 = UIImageView()
    
    var moviePic3 = UIImageView()
    
    var moviePic4 = UIImageView()

}
