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
        let movies = SingleMovie().getCurrentLikedMovies(key: AWSIdentityManager.default().identityId!)
        let userLikedHistory = HistoryMovie().userLikedHistoryMovies(_userID: AWSIdentityManager.default().identityId!)

        
        return (movies.count + userLikedHistory.count)
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = movieCollectionView.dequeueReusableCell( withReuseIdentifier: "CustomCell", for: indexPath) as! MovieCollectionCell
        
        updateMovieImages()
        
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        cell.movieImage.image = nil
        cell.movieTitleLabel.text = ""
        
        DispatchQueue.main.async {
            cell.movieImage.image = self.images[indexPath.row]
            cell.movieImage.contentMode = .scaleAspectFill
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
        
        //add movies that are currently showing
        let movies = SingleMovie().getCurrentLikedMovies(key: AWSIdentityManager.default().identityId!)
        
        self.images = [UIImage]()
        self.titles = [String]()
        self.historyTitles = [String]()
        var image = UIImage()
        
        for movie in movies {
            let path = "https://image.tmdb.org/t/p/w342" + movie.poster_path!
            let pathURL = URL(string: path)
            let imageData = try! Data(contentsOf: pathURL!)
            image = UIImage(data: imageData)!
            images.append(image)
            titles.append(movie.title)
        }
        
        //add movies that are no longer showing
        let userLikedHistory = HistoryMovie().userLikedHistoryMovies(_userID: AWSIdentityManager.default().identityId!)
        
        for movie in userLikedHistory {
            let path = "https://image.tmdb.org/t/p/w342" + movie.poster_path!
            let pathURL = URL(string: path)
            let imageData = try! Data(contentsOf: pathURL!)
            image = UIImage(data: imageData)!
            images.append(image)
            titles.append(movie.title)
            historyTitles.append(movie.title)
        }
        
        
        print("there are total: ")
        print(images.count)
        
        
    }
    
    func isHistory(movieTitle:String)-> (_: Bool) {
        
        for var title in historyTitles {
            if (title == movieTitle){
                return true;
            }
        }
        return false;
    }
    
    
    let imagecache = NSCache<AnyObject, AnyObject>()
    var images: [UIImage]!
    var titles: [String]!
    var historyTitles: [String]!
    @IBOutlet weak var movieCollectionView: UICollectionView!

}






