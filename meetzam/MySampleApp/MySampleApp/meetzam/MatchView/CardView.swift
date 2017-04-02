//
//  CardView.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/23/17.
//
//

import UIKit

class CardView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        
        
        //profile picture
        self.addSubview(userPicField)
        
        // user name
        displayName.frame = CGRect(x: 20, y: userPicField.frame.height + 5, width: UIScreen.main.bounds.width-30, height: 30)
        displayName.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        self.addSubview(displayName)
        
        // user bio
        userBioField.frame = CGRect(x: 20, y: userPicField.frame.height + 35, width: UIScreen.main.bounds.width-30, height: 20)
        userBioField.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        userBioField.textColor = UIColor.gray
        self.addSubview(userBioField)
        
        // also liked
        let alsoLiked = UILabel()
        alsoLiked.text = "Also liked"
        alsoLiked.frame = CGRect(x: 20, y: userPicField.frame.height + 70, width: UIScreen.main.bounds.width-30, height: 20)
        alsoLiked.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        alsoLiked.textColor = UIColor.darkGray
        self.addSubview(alsoLiked)
        
        // collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: UIScreen.main.bounds.width + 70, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 90, height: 140)
        
        likedMoviesCollectionView = UICollectionView(frame: CGRect(x: 0, y: UIScreen.main.bounds.width + 70, width: UIScreen.main.bounds.width-30, height: 140), collectionViewLayout: layout)
        likedMoviesCollectionView.dataSource = self
        likedMoviesCollectionView.delegate = self
        likedMoviesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        likedMoviesCollectionView.backgroundColor = UIColor.init(red: 173/255, green: 173/255, blue: 173/255, alpha: 1)
        self.addSubview(likedMoviesCollectionView)

    }
    
    var userPicField = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-30, height: UIScreen.main.bounds.width-30))
    
    let displayName = UILabel()
    
    let userBioField = UILabel()
    
    var likedMoviesCollectionView: UICollectionView!
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topThreeImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = likedMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! TopThreeMovieCell
        cell.Top3MovieImage.image = UIImage(named: topThreeImages[indexPath.row])
        
        return cell
    }
    
    var topThreeImages = ["split","loganposter2","lala"]

    
}
