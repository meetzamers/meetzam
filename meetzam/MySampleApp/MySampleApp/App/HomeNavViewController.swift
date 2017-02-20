//
//  HomeNavViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/20/17.
//
//

import UIKit

class HomeNavViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func gotoHomeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "gotoHomeSegue", sender: self)
        
    }

}
