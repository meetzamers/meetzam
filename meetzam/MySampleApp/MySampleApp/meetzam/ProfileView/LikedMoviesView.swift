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
        let movies = SingleMovie().getAllLikedMovies(key: AWSIdentityManager.default().identityId!)
        
        return movies.count
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
        
        for var title in self.titles {
            if (self.isHistory(movieTitle: title)){
                cell.movieTitleLabel.textColor = UIColor.gray
            } else {
                cell.movieTitleLabel.textColor = UIColor.black
            }
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
        
        
        let allHistoryMovies = HistoryMovie().getAllHistoryMovies()
        userLikedHistory = HistoryMovie().userLikedHistoryMovies(userLikedMovies: movies, historyMovies: allHistoryMovies)
        
        
    }
    
    func isHistory(movieTitle:String)-> (_: Bool) {
        
        for var movie in userLikedHistory {
            if (movie.title == movieTitle){
                return true;
            }
        }
        return false;
    }
    
    
    let imagecache = NSCache<AnyObject, AnyObject>()
    var images: [UIImage]!
    var titles: [String]!
    var userLikedHistory: [HistoryMovie]!
    @IBOutlet weak var movieCollectionView: UICollectionView!

}






