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
    var cardsToLoad = 2
    // ========================================
    
    // functions:
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.swipeableView.didSwipe = {view, direction, vector in
                if (self.lablecount < self.userIds.count) {
                    
                    print("i am swiping \(self.lablecount-self.cardsToLoad) th user")
                    if (direction == Direction.Right){
                        UserProfileToDB().likeOneUser(key: AWSIdentityManager.default().identityId!, likedUserID: self.userIds[self.lablecount-self.cardsToLoad])
                        
                        print("I liked \(self.displayNames[self.lablecount-self.cardsToLoad])")
                        if (UserProfileToDB().findIsMatched(key: AWSIdentityManager.default().identityId!, userID: self.userIds[self.lablecount-self.cardsToLoad])){
                            print("Congradulations!! You have a new match!!")
                        }
                    }
                    
                } else {
                    self.swipeableView.removeFromSuperview()
                }
            }
        swipeableView.nextView = {
            return self.nextCardView()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // ========================================
        let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        
        // Card View implementation
        swipeableView = ZLSwipeableView(frame: CGRect(x: UIScreen.main.bounds.width*0.04 ,y: 72, width: UIScreen.main.bounds.width*0.92, height: UIScreen.main.bounds.height*0.86))
        
        /*
        if (matchedUserIDs.count <= 3){
            swipeableView.numberOfActiveView = UInt(matchedUserIDs.count)
        } else {
            swipeableView.numberOfActiveView = UInt(3)
        }
        */
        swipeableView.numberOfActiveView = UInt(cardsToLoad)
        view.addSubview(swipeableView)
        // ========================================
        
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
        
        loadPotentialMatch()


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
        /*
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
        */
        //cardView.userPicField.image = profilePics[lablecount]
        
 
        if (lablecount < displayNames.count) {
            // assign potential matches' DISPLAYNAME to cardView
            cardView.displayName.text = displayNames[lablecount]
        
            // assign potential matches' BIO to cardView
            cardView.userBioField.text = bios[lablecount]
        
    
            if (lablecount >= displayNames.count - cardsToLoad ) {
                cardView.backgroundLabel.backgroundColor = UIColor.white
                cardView.alsoLiked.text = ""
                cardView.displayName.text = "You have reached the end!"
            } else {
                // assign potential matches' LIKEDMOVIES to cardView
                cardView.moviePic1.image = movies1[lablecount]
                cardView.moviePic2.image = movies2[lablecount]
                cardView.moviePic3.image = movies3[lablecount]
            }
        }
        
        lablecount += 1
 
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
    
    //Monika
    func loadPotentialMatch(){
        displayNames = [String]()
        userIds = [String]()
        bios = [String]()
        movies1 = [UIImage]()
        movies2 = [UIImage]()
        movies3 = [UIImage]()
        
        let matchedUserIDs = UserProfileToDB().getMatchedUserIDs(key: AWSIdentityManager.default().identityId!)
        let matchedUsers = UserProfileToDB().getMatchedUserProfiles(userIDs: matchedUserIDs)
        
        print("I have this many potential matches: \(matchedUsers.count)")
        for matchedUser in matchedUsers
        {
            //add names to displayNames
            displayNames.append(matchedUser.displayName!)
            //add user id to userIds
            userIds.append(matchedUser.userId!)
            //add bios to displayNames
            if (matchedUser.bio == nil)
            {
                bios.append("")
            } else {
                bios.append(matchedUser.bio!)
            }
            //add pictures to movies1,2,3
            loadMovies(userId: matchedUser.userId!)
            //loadProfile(userId: matchedUser.userId!)
            
        }
        
        
        
        //add cardsToLoad # of blank pages at the end.
        for var i in (0..<cardsToLoad){
            displayNames.append("")
            userIds.append("")
            bios.append("")
        }
        
        
    }
    func loadProfile(userId: String) {
        let profileURL = UserProfileToDB().downloadUserIcon(userID: userId)
        let profileData = try! Data(contentsOf: profileURL)
        profilePics.append(UIImage(data: profileData)!)
    }
    
    func loadMovies(userId: String) {
        let imagesURLs = SingleMovie().getLikedMoviePosters(key: userId)
        
        var count = 0;
        if (imagesURLs.count <= 3) {
            count = imagesURLs.count
        } else {
            count = 3
        }
        
        for var i in (0..<count) {
            let path = "https://image.tmdb.org/t/p/w154" + imagesURLs[i]
            let pathURL = URL(string: path)
            let imageData = try! Data(contentsOf: pathURL!)

            if (i==0) {
                movies1.append(UIImage(data: imageData)!)
            } else if (i==1){
                movies2.append(UIImage(data: imageData)!)
            } else if (i==2){
                movies3.append(UIImage(data: imageData)!)
            }
        }
        
        while (count<3){
            if (count==0) {
                movies1.append(#imageLiteral(resourceName: "emptyMovie"))
            } else if (count==1){
                movies2.append(#imageLiteral(resourceName: "emptyMovie"))
            } else if (count==2){
                movies3.append(#imageLiteral(resourceName: "emptyMovie"))
            }
            count+=1
        }

    }
    
    var displayNames: [String]!
    var userIds: [String]!
    var bios: [String]!
    var movies1: [UIImage]!
    var movies2: [UIImage]!
    var movies3: [UIImage]!
    var profilePics: [UIImage]!
}
