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
        
        movieCollectionView.reloadData()
        
        self.view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        
                /*
        print("     put into imagesURLs")
        print("-------------------------------------------------")
        for url in imagesURLs {
            print("This is url \(url)")
        }
        */
        /*
        var imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)

        let count = imagesURLs.count;
        
        imageData = [Data]()
        imageData.removeAll()
        
        for var i in (0..<count) {
            let path = "https://image.tmdb.org/t/p/w500" + imagesURLs[i]
            let pathURL = URL(string: path)
            imageData.insert(try! Data(contentsOf: pathURL!),at:0)
        }
         */

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       /* var imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        
        let count = imagesURLs.count;
        imageData = [Data]()
        imageData.removeAll()
        
        for var i in (0..<count) {
            let path = "https://image.tmdb.org/t/p/w500" + imagesURLs[i]
            let pathURL = URL(string: path)
            //imageData.append(try! Data(contentsOf: pathURL!))
            imageData.insert(try! Data(contentsOf: pathURL!),at:0)
        }
        */
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
        
        var imageData = updateMovieImages()
        
        cell.movieImage.image = nil
        cell.movieImage.image = UIImage(data: imageData[indexPath.row])
        
        cell.movieTitleLabel.text = "hello"
    
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        

        return cell
    }
    
    public func updateMovieImages() -> [Data] {
        let imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        
        //let count = imagesURLs.count;
        var imageData = [Data]()
        //imageData.removeAll()
        
        for item in imagesURLs {
            let path = "https://image.tmdb.org/t/p/w500" + item
            let pathURL = URL(string: path)
            //imageData.append(try! Data(contentsOf: pathURL!))
            imageData.insert(try! Data(contentsOf: pathURL!),at:0)
        }
        
        return imageData
    }
    
    @IBOutlet weak var movieCollectionView: UICollectionView!

    
}






