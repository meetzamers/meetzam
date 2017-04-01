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
        
        var imageData = updateMovieImages()
        
        cell.movieTitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        
        cell.movieImage.image = nil
        DispatchQueue.main.async {
            cell.movieImage.image = imageData[indexPath.row]
        }
        var text = ["1","2","3","4","5","6"]
        cell.movieTitleLabel.text = text[indexPath.row]
        return cell
    }
    
    func updateMovieImages() -> [UIImage] {
        let imagesURLs = SingleMovie().getLikedMoviePosters(key: AWSIdentityManager.default().identityId!)
        
        
        var images = [UIImage]()
        var image = UIImage()
        for item in imagesURLs {
            let path = "https://image.tmdb.org/t/p/w500" + item
            
            /* abc's method */
            //image = self.loadImageUsingURL(urlString: path)
            
            /* my method */
            //DispatchQueue.main.async {
            let pathURL = URL(string: path)
            let imageData = try! Data(contentsOf: pathURL!)
            image = UIImage(data: imageData)!
            /* my method */
            
            images.append(image)
            //}
            
        }
        
        print("there are total: ")
        print(images.count)
        return images
        
    }
    
    
    let imagecache = NSCache<AnyObject, AnyObject>()
    var image: UIImage!
    @IBOutlet weak var movieCollectionView: UICollectionView!

    
    
}






