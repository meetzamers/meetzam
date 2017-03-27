//
//  LikedMoviesView.swift
//  MySampleApp
//
//  Created by 孟琦 on 2/28/17.
//
//

import UIKit
import AWSMobileHubHelper

class LikedMoviesView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
       
    }
    
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! MovieCollectionCell
        
        
        cell.movieImage.image = UIImage(named: images[indexPath.row])
        let imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        print("     put into imagesURLs")
        print("-------------------------------------------------")
        for url in imagesURLs {
            print("This is url \(url)")
        }
        return cell
    }

    
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var images = ["split","loganposter2","lala"]
    


}
