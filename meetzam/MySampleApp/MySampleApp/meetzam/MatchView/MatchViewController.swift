//
//  MatchViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit
import ZLSwipeableViewSwift

class MatchViewController: UIViewController {
    
    // ========================================
    
    // Var:
    var swipeableView: ZLSwipeableView!
    
    // Because I set the labelcount here, it will set to 0 whenever this page appears.
    var lablecount = 0
    
    // ========================================
    
    // functions:
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        
        // ========================================
        // Card View implementation
        swipeableView = ZLSwipeableView(frame: CGRect(x: UIScreen.main.bounds.width*0.04 ,y: 72, width: UIScreen.main.bounds.width*0.92, height: UIScreen.main.bounds.height*0.86))
        
        swipeableView.numberOfActiveView = UInt(3)
        view.addSubview(swipeableView)
        // ========================================
        
    }
    
    func nextCardView() -> UIView? {
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = UIColor.init(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        // ========================================
        // you can display data on the card view here:
        let testlabel = UILabel.init(frame: CGRect(x: cardView.bounds.width*0.25 ,y: cardView.bounds.height*0.6, width: 200, height: 200))
        lablecount += 1
        var re_string = "This is page number "
        re_string += String(lablecount)
        testlabel.text = re_string
        
        // Add the objects on the card view
        cardView.addSubview(testlabel)
        // ========================================
        
        return cardView
    }

    // ========================================
    // buttons:
    @IBAction func backHomeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarFirst")

        self.present(viewController, animated: false, completion: nil)
        
    }
    
    @IBAction func toChatButton(_ sender: Any) {
        
        
    }
    

}
