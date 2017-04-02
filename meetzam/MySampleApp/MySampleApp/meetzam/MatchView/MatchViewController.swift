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
        self.swipeableView.didSwipe = {view, direction, vector in
                if (self.lablecount < self.userIds.count) {
                    
                    print("i am swiping \(self.lablecount-self.cardsToLoad) th user")
                    if (direction == Direction.Right){
                        UserProfileToDB().likeOneUser(key: AWSIdentityManager.default().identityId!, likedUserID: self.userIds[self.lablecount-self.cardsToLoad])
                        
                        print("I liked \(self.displayNames[self.lablecount-self.cardsToLoad])")
                        print("My match's ID is \(self.userIds[self.lablecount-self.cardsToLoad])")
                        if (UserProfileToDB().findIsMatched(key: AWSIdentityManager.default().identityId!, userID: self.userIds[self.lablecount-self.cardsToLoad]) && UserProfileToDB().findIsMatched(key: self.userIds[self.lablecount-self.cardsToLoad], userID: AWSIdentityManager.default().identityId!)){
                            print("Congradulations!! You have a new match!! with \(self.displayNames[self.lablecount-self.cardsToLoad])")
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
        
        /*let likedUserIDs = UserProfileToDB().getLikedUserIDs(key: AWSIdentityManager.default().identityId!)
        for userid in likedUserIDs
        {
            print("one of your liked users is \(userid)")
        }
        UserProfileToDB().insertToMatchedUser(key: AWSIdentityManager.default().identityId!, userID: "us-east-1:f0739f93-42d3-4ad8-9ddf-ca8f06cdfff2")*/
        
        // Card View implementation
        swipeableView = ZLSwipeableView(frame: CGRect(x: UIScreen.main.bounds.width*0.04 ,y: 72, width: UIScreen.main.bounds.width*0.92, height: UIScreen.main.bounds.height*0.86))
        
        // Swipe Left and Right Images
        swipeRightImage.frame = CGRect(x: 15 ,y: 15, width: 60, height: 60)
        swipeLeftImage.frame = CGRect(x: swipeableView.bounds.width - 75 ,y: 15, width: 60, height: 60)
        
        
        /*
        if (matchedUserIDs.count <= 3){
            swipeableView.numberOfActiveView = UInt(matchedUserIDs.count)
        } else {
            swipeableView.numberOfActiveView = UInt(3)
        }
        */
        // Framework init
        swipeableView.numberOfActiveView = UInt(cardsToLoad)
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
        loadPotentialMatch()
    }
    
    func nextCardView() -> UIView? {
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = UIColor.init(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
   
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
        
 
        if (lablecount < displayNames.count) {
            // assign potential matches' DISPLAYNAME to cardView
            cardView.displayName.text = displayNames[lablecount]
        
            // assign potential matches' BIO to cardView
            cardView.userBioField.text = bios[lablecount]
        
    
            if (lablecount >= displayNames.count - cardsToLoad ) {
                cardView.backgroundLabel.backgroundColor = UIColor.white
                cardView.alsoLiked.text = ""
                if (lablecount == displayNames.count - cardsToLoad){
                    cardView.displayName.text = "You have reached the end!"
                }
            } else {
                // assign potential matches' LIKEDMOVIES to cardView
                cardView.moviePic1.image = movies1[lablecount]
                cardView.moviePic2.image = movies2[lablecount]
                cardView.moviePic3.image = movies3[lablecount]
                cardView.userPicField.image = profilePics[lablecount]
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
        profilePics = [UIImage]()
        
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
            loadProfile(userId: matchedUser.userId!)
            
        }
        
        
        //add cardsToLoad # of blank pages at the end.
        for var i in (0..<cardsToLoad){
            displayNames.append("")
            userIds.append("")
            bios.append("")
        }
        
        
    }
    func loadProfile(userId: String) {
        let URLString = UserProfileToDB().downloadUserIcon(userID: userId).path
        print("the local directory is \(URLString)")
        if FileManager.default.fileExists(atPath: URLString) {
            print("The file exists!! \(userId)")
            let profileURL = NSURL(string: URLString)
            let profileData = NSData(contentsOf: profileURL! as URL)
            profilePics.append(UIImage(data: profileData! as Data)!)
        } else {
            profilePics.append(#imageLiteral(resourceName: "emptyMovie"))
        }
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
