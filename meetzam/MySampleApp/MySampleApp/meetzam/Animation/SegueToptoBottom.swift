//
//  SegueToptoBottom.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit

class SegueToptoBottom: UIStoryboardSegue {
    // perform segue
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { (Finished) in
            src.present(dst, animated: false, completion: nil)
        }
        
    }
    
}

