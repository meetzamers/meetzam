//
//  CardView.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/23/17.
//
//

import UIKit

class CardView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 3.0;
        
        /*  Monika  */
        //profile picture
        self.addSubview(userPicField)
        
        // user name
        displayName.frame = CGRect(x: 25, y: userPicField.frame.height + 10, width: UIScreen.main.bounds.width-30, height: 30)
        displayName.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        self.addSubview(displayName)
        
        // user bio
        userBioField.frame = CGRect(x: 25, y: userPicField.frame.height + 40, width: UIScreen.main.bounds.width-30, height: 20)
        userBioField.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        userBioField.textColor = UIColor.gray
        self.addSubview(userBioField)
        
        // also liked
        alsoLiked.text = "Liked"
        alsoLiked.frame = CGRect(x: 25, y: userPicField.frame.height + 70, width: UIScreen.main.bounds.width-30, height: 20)
        alsoLiked.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        alsoLiked.textColor = UIColor.darkGray
        self.addSubview(alsoLiked)
        
        
        // liked movie backgroundLabel
        backgroundLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.width + 70, width: UIScreen.main.bounds.width-30, height: 140)
        backgroundLabel.text = ""
        backgroundLabel.backgroundColor = UIColor.init(red: 173/255, green: 173/255, blue: 173/255, alpha: 1)
        self.addSubview(backgroundLabel)
        
        
        // movies
        moviePic1.frame = CGRect(x: 0, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width-30)/4, height: 140)
        moviePic2.contentMode = .scaleToFill
        
        moviePic2.frame = CGRect(x: moviePic1.frame.width, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width-30)/4, height: 140)
        
        moviePic3.frame = CGRect(x: moviePic1.frame.width*2, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width-30)/4, height: 140)
        
        //moviePic4.frame = CGRect(x: moviePic1.frame.width*3, y: UIScreen.main.bounds.width + 70, width: (UIScreen.main.bounds.width-30)/4, height: 140)
        
        
        self.addSubview(moviePic1)
        self.addSubview(moviePic2)
        self.addSubview(moviePic3)
        //self.addSubview(moviePic4)
        /* Monika */


    }
    
    var userPicField = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-30, height: UIScreen.main.bounds.width-30))
    
    let displayName = UILabel()
    
    let userBioField = UILabel()
    
    let alsoLiked = UILabel()
    
    let backgroundLabel = UILabel()
    
    var moviePic1 = UIImageView()
    
    var moviePic2 = UIImageView()
    
    var moviePic3 = UIImageView()
    
    var moviePic4 = UIImageView()
    
    

    
}
