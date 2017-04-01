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
        
        //movieCollectionView.reloadData()
        
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

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       DispatchQueue.main.async {
            self.movieCollectionView.reloadData()
        }
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
        
        updateMovieImages()
        
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        
        cell.movieImage.image = nil
        cell.movieTitleLabel.text = ""
        DispatchQueue.main.async {
            cell.movieImage.image = self.images[indexPath.row]
        }
        DispatchQueue.main.async {
            cell.movieTitleLabel.text = self.titles[indexPath.row]
        }

        return cell
    }
    
    func updateMovieImages() {
        let movies = SingleMovie().getAllLikedMovies(key: AWSIdentityManager.default().identityId!)
        
        self.images = [UIImage]()
        self.titles = [String]()
        var image = UIImage()
        
        for movie in movies {
            let path = "https://image.tmdb.org/t/p/w500" + movie.poster_path!
            let pathURL = URL(string: path)
            let imageData = try! Data(contentsOf: pathURL!)
            image = UIImage(data: imageData)!
            images.append(image)
            titles.append(movie.title)
        }
        
        print("there are total: ")
        print(images.count)
    }
    
    let imagecache = NSCache<AnyObject, AnyObject>()
    var images: [UIImage]!
    var titles: [String]!
    @IBOutlet weak var movieCollectionView: UICollectionView!

}






