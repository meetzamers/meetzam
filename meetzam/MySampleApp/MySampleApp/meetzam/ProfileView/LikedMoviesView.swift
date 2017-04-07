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
        
        movieCollectionView.alwaysBounceHorizontal = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       DispatchQueue.main.async {
            self.movieCollectionView.reloadData()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let movies = SingleMovie().getCurrentLikedMovies(key: AWSIdentityManager.default().identityId!)
        let userLikedHistory = HistoryMovie().userLikedHistoryMovies(_userID: AWSIdentityManager.default().identityId!)

        
        return (movies.count + userLikedHistory.count)
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = movieCollectionView.dequeueReusableCell( withReuseIdentifier: "CustomCell", for: indexPath) as! MovieCollectionCell
        
        updateMovieImages()
        
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        cell.movieTitleLabel.textColor = UIColor.black
        cell.movieImage.image = nil
        cell.movieTitleLabel.text = ""
        
        DispatchQueue.main.async {
            cell.movieImage.loadImageUsingURLString(URLString: self.imageURLs[indexPath.row])
//            cell.movieImage.image = self.imageViews[indexPath.row].image
            cell.movieImage.contentMode = .scaleAspectFill
        }
        
        
        for var i in (0..<(self.titles.count)) {
            if (self.isHistory(movieTitle: titles[i])){
                if (i == indexPath.row){
                    cell.movieImage.alpha = 0.5
                    cell.movieTitleLabel.textColor = UIColor.darkGray
                }
            }
        }
        
        DispatchQueue.main.async {
            cell.movieTitleLabel.text = self.titles[indexPath.row]
        }
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    func updateMovieImages() {
        
        //add movies that are currently showing
        let movies = SingleMovie().getCurrentLikedMovies(key: AWSIdentityManager.default().identityId!)
        
        self.imageURLs = [String]()
        self.titles = [String]()
        self.historyTitles = [String]()
        
        for movie in movies {
            let path = "https://image.tmdb.org/t/p/w342" + movie.poster_path!
            imageURLs.append(path)
            titles.append(movie.title)
        }
        
        //add movies that are no longer showing
        let userLikedHistory = HistoryMovie().userLikedHistoryMovies(_userID: AWSIdentityManager.default().identityId!)
        
        for movie in userLikedHistory {
            let path = "https://image.tmdb.org/t/p/w342" + movie.poster_path!
            imageURLs.append(path)
            titles.append(movie.title)
            historyTitles.append(movie.title)
            print("I just added \(movie.title)")
        }
        
        print("there are total: ")
//        print(images.count)
        
    }
    
    func isHistory(movieTitle:String)-> (_: Bool) {
        //print("I just got \(movieTitle)")
        for var title in historyTitles {
            print("I am comparing \(movieTitle) with \(title)")
            if (title == movieTitle){
                return true;
            }
        }
        return false;
    }
    
    let imagecache = NSCache<AnyObject, AnyObject>()
    var imageURLs: [String]!
    var titles: [String]!
    var historyTitles: [String]!
    @IBOutlet weak var movieCollectionView: UICollectionView!

}
