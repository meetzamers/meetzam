//
//  MatchViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit
import ZLSwipeableViewSwift
import AWSMobileHubHelper

class MatchViewController: UIViewController {
    
    // ========================================
    
    // Var:
    var swipeableView: ZLSwipeableView!
    
    // Swipe Right Heart image
    let swipeRightImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "DoHeart")
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    // Swipe Left Cancel image
    let swipeLeftImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "MatchCancel")
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
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
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // ========================================
        // Card View implementation
        swipeableView = ZLSwipeableView(frame: CGRect(x: UIScreen.main.bounds.width*0.04 ,y: 72, width: UIScreen.main.bounds.width*0.92, height: UIScreen.main.bounds.height*0.86))
        
        // Swipe Left and Right Images
        swipeRightImage.frame = CGRect(x: 15 ,y: 15, width: 60, height: 60)
        swipeLeftImage.frame = CGRect(x: swipeableView.bounds.width - 75 ,y: 15, width: 60, height: 60)
        
        // Framework init
        swipeableView.numberOfActiveView = UInt(3)
        view.addSubview(swipeableView)
        
        // Left and Right images init
        var startLocation = CGFloat()
        var prevLocation = CGFloat()
        
        // User did start swiping
        swipeableView.didStart = {view, location in
            startLocation = location.x
            self.swipeableView.activeViews()[0].addSubview(self.swipeRightImage)
            self.swipeRightImage.alpha = 0
            self.swipeableView.activeViews()[0].addSubview(self.swipeLeftImage)
            self.swipeLeftImage.alpha = 0
        }
        
        // User is swiping
        swipeableView.swiping = {view, location, translation in
            // if swipe right
            if (location.x > startLocation) {
                self.swipeRightImage.alpha = (location.x - startLocation)*2/(UIScreen.main.bounds.width - startLocation)
                self.swipeLeftImage.alpha = 0
            }
                // if swipe left
            else {
                self.swipeRightImage.alpha = 0
                self.swipeLeftImage.alpha = -((location.x - startLocation)*2/(UIScreen.main.bounds.width - startLocation))
            }
            prevLocation = location.x
        }
        
        // User did end swiping
        swipeableView.didEnd = {view, location in
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.swipeRightImage.alpha = 0
                self.swipeRightImage.removeFromSuperview()
                self.swipeLeftImage.alpha = 0
                self.swipeLeftImage.removeFromSuperview()
            })
        }
        // ========================================
        let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        /*for matchID in matchedUserIDs
        {
            print("match with you: \(matchID)")
        }
        let matchedUsers = UserProfileToDB().getMatchedUserProfiles(userIDs: matchedUserIDs)
        for matchUser in matchedUsers
        {
            print("your buddies are: \(matchUser.displayName)")
        }
        let allHistoryMovies = HistoryMovie().getAllHistoryMovies()
        for history_movie in allHistoryMovies
        {
            print("history movie is: \(history_movie.title)")
        }*/
    }
    
    func nextCardView() -> UIView? {
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = UIColor.init(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
   
        // temperoray profile pic
        let identityManager = AWSIdentityManager.default()
        AWSIdentityManager.default()
        if let imageURL = identityManager.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                cardView.userPicField.image = profileImage
            } else {
                cardView.userPicField.image = UIImage(named: "UserIcon")
            }
        }
        
        // temp user name
        cardView.displayName.text = "Monika"
        
        // temp user bio
        cardView.userBioField.text = "Hello :) Nice to meet you!!"
        
        
        return cardView
    }
    
    // ========================================    
    // buttons:
    @IBAction func backHomeButton(_ sender: Any) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarFirst")
        //self.present(viewController, animated: false, completion: nil)
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
}
