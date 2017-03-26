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
        
        var imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        /*
        print("     put into imagesURLs")
        print("-------------------------------------------------")
        for url in imagesURLs {
            print("This is url \(url)")
        }
        */
        let count = imagesURLs.count;
        
        imageData.removeAll()
        
        for var i in (0..<count) {
            let path = "https://image.tmdb.org/t/p/w500" + imagesURLs[i]
            let pathURL = URL(string: path)
            imageData.append(try! Data(contentsOf: pathURL!))
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        var imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        
        let count = imagesURLs.count;
        imageData.removeAll()
        
        for var i in (0..<count) {
            let path = "https://image.tmdb.org/t/p/w500" + imagesURLs[i]
            let pathURL = URL(string: path)
            imageData.append(try! Data(contentsOf: pathURL!))
        }
        
        movieCollectionView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
       
    }
    
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        return imagesURLs.count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell( withReuseIdentifier: "CustomCell", for: indexPath) as! MovieCollectionCell
        
        
        //cell.movieImage.image = UIImage(named: images[indexPath.row])
        cell.movieImage.image = UIImage(data: imageData[indexPath.row])
        
        cell.movieTitleLabel.text = "hello"
    
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        
        return cell
    }
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var imageData = [Data]()
    
}




