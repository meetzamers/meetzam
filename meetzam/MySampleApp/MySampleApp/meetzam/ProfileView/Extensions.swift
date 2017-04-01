//
//  Extensions.swift
//  MySampleApp
//
//  Created by 孟琦 on 3/31/17.
//
//

import UIKit


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImage {
    
    
    func loadImageUsingUrlString(urlString: String) {
        
        var imageUrlString = urlString
        
        let url = NSURL(string: urlString)
        
        self = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageToCache = UIImage(data: data!)
                
                
                self = imageToCache
                
                
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
            })
            
        }).resume()
    }
    
}
