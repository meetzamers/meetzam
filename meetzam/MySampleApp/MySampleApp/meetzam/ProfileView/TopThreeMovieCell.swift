//
//  TopThreeMovieCell.swift
//  MySampleApp
//
//  Created by 孟琦 on 3/1/17.
//
//

import UIKit

class TopThreeMovieCell: UICollectionViewCell {
    
    @IBOutlet weak var Top3MovieImage: UIImageView!
    
    override func prepareForReuse() {
        Top3MovieImage.image = nil
    }
    
}
