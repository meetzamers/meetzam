//
//  LikedMoviesView.swift
//  MySampleApp
//
//  Created by 孟琦 on 2/28/17.
//
//

import UIKit

class LikedMoviesView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return cell
    }

    
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var images = ["split","loganposter2","lala"]
    


}
