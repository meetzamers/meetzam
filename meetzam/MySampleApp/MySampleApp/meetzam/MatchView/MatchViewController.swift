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
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // ========================================
        // Card View implementation
        swipeableView = ZLSwipeableView(frame: CGRect(x: UIScreen.main.bounds.width*0.04 ,y: 72, width: UIScreen.main.bounds.width*0.92, height: UIScreen.main.bounds.height*0.86))
        
        swipeableView.numberOfActiveView = UInt(3)
        view.addSubview(swipeableView)
        // ========================================
        let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        for matchID in matchedUserIDs
        {
            print("match with you: \(matchID)")
        }
        let likedMovies = SingleMovie().getCurrentLikedMovies(key: AWSIdentityManager.default().identityId!)
        for movie in likedMovies
        {
            print("one of your liked movies is \(movie.title)")
        }
        let historyLikedMovies = HistoryMovie().userLikedHistoryMovies(_userID: AWSIdentityManager.default().identityId!)
        for history_liked in historyLikedMovies
        {
            print("one of your history liked movies is \(history_liked.title)")
        }
        /*let matchedUsers = UserProfileToDB().getMatchedUserProfiles(userIDs: matchedUserIDs)
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
        
        /* ========================================
        // you can display data on the card view here:
        let testlabel = UILabel.init(frame: CGRect(x: cardView.bounds.width*0.25 ,y: cardView.bounds.height*0.6, width: 200, height: 200))
        lablecount += 1
        var re_string = "This is page number "
        re_string += String(lablecount)
        testlabel.text = re_string
        
        // Add the objects on the card view
        cardView.addSubview(testlabel)
        // ========================================*/
        
        
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
