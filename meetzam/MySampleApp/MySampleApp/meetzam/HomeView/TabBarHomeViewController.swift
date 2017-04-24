//
//  TabBarHomeViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/20/17.
//
//  Mushroom05:
//      adding global movie array in variables section
//      adding handler function
//      import AWS dynamodb

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import NVActivityIndicatorView

class TabBarHomeViewController:  UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    // ============================================
    // Variable starts here
    var new_signinObserver: AnyObject!
    var new_signoutObserver: AnyObject!
    
    var isFirstMovieView = false
    //mush
    var movielist = MovieList()
    var movieView = FrameViewController()
    var user_p = UserProfileToDB()
    var uplist = [UpcomMovie]()
    
    // Variable ends here
    // ============================================
    // Change status bar type to default.
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Let self be the delegate and dataSource
        self.delegate = self
        self.dataSource = self
        
        AWSLogger.default().logLevel = .none
        
        // This is the first movie
        if (!AWSIdentityManager.default().isLoggedIn) {
            self.isFirstMovieView = true
        }
        
        // change background color to grey
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        let frameVC = movieView
        let viewControllers = [frameVC]
        
        setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        // ============================================
        // AWS implementation starts here
        // 1. first attempt to pop sign in view controller
        perform(#selector(popSignInViewController), with: nil, afterDelay: 0)
        
        // 1.5 attempt to pop first time user view controller
//        perform(#selector(popFirstUserViewController), with: nil, afterDelay: 0)
        
        // 2. signinObserver: need to figure it out.
        new_signinObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard self != nil else { return }
                print("Sign in observer observed sign in.")
        })
        
        // 3. signoutObserver: need to figure it out.
        new_signoutObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignOut,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard self != nil else { return }
                print("Sign Out Observer observed sign out.")
        })
        
        // AWS implementation ends here
        // ============================================
        if (AWSIdentityManager.default().isLoggedIn) {
            if let arn = UserProfileToDB().getDeviceArn() {
                API().addDeviceARNtoDB(userId: AWSIdentityManager.default().identityId!, deviceARN: arn)
            }
            //get user liked movies initially
            UserProfileToDB().getLikedMovies(userId: AWSIdentityManager.default().identityId!, user_profile: user_p!)
            //get homescreen movie list
            //actually if we discard the executor; mainThread(),
            //we might be able to discard the movieView thingy
            //since without that the method will run asynchronizedly and return immediately
            SingleMovie().refreshList(movie_list: movielist, view: movieView, user_profile: user_p!)
            uplist = UpcomMovie().upcomList();
            //print(uplist.description)
        }
        
    }
    
    // ============================================
    // AWS support functions start here
    deinit {
        NotificationCenter.default.removeObserver(new_signinObserver)
        NotificationCenter.default.removeObserver(new_signoutObserver)
    }
    
    // display sign in view controller
    func popSignInViewController() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.present(viewController, animated: false, completion: nil)
            
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // display first time view controller
    func popFirstUserViewController() {
        // ======================================================================================================
        // TODO: check if this is new user:
        if (AWSIdentityManager.default().isLoggedIn) {
            if let myID = AWSIdentityManager.default().identityId {
                if (!UserProfileToDB().isUserIDinTable(_userId: myID)) {
                    print("First Time User")
                    let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "FirstTimeUser")
                    self.present(viewController, animated: false, completion: nil)
                }
            }
        }
    }
    
    // AWS support functions end here
    // ============================================
    // Page view functions start here
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var currentIndex: Int
        if ((viewController as! FrameViewController).current) {
            currentIndex = movielist.tableRows.index(of: (viewController as! FrameViewController).movie_info!)!
        }
        else {
            currentIndex = movielist.tableRows.count + uplist.index(of: (viewController as! FrameViewController).up_movie_info!)!
        }
        
        if (currentIndex < movielist.tableRows.count - 1) {
            let frameVC = FrameViewController()
            frameVC.current = true
            frameVC.movie_info = movielist.tableRows[currentIndex + 1]
            
            print("next movie is of index \(currentIndex) with name " + (frameVC.movie_info?.title)!)
            print("review \(String(describing: frameVC.movie_info?.comment_body))")
            //mush: like
            if (user_p?.currentLikedMovie.contains((frameVC.movie_info?.title)!))! {
                print("swipe left:FOUND THE MOVIE IN LIKED LIST")
                frameVC.like = true
            }
            else {
                print("swipe left:NOT LIKED")
            }
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            user_p?.currentLikedMovie.removeAll()
            UserProfileToDB().getLikedMovies(userId: AWSIdentityManager.default().identityId!, user_profile: user_p!)
            
            return frameVC
        }
        else if (currentIndex - movielist.tableRows.count < uplist.count - 1) {
            let frameVC = FrameViewController()
            frameVC.current = false
            frameVC.up_movie_info = uplist[currentIndex - movielist.tableRows.count + 1]
            
            print("next movie is \(currentIndex) with name " + (frameVC.up_movie_info?.title)!)
            //mush: like
            if (user_p?.currentLikedMovie.contains((frameVC.up_movie_info?.title)!))! {
                print("swipe left:FOUND THE MOVIE IN LIKED LIST")
                frameVC.like = true
            }
            else {
                print("swipe left:NOT LIKED")
            }
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            user_p?.currentLikedMovie.removeAll()
            UserProfileToDB().getLikedMovies(userId: AWSIdentityManager.default().identityId!, user_profile: user_p!)
            
            return frameVC

        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var currentIndex: Int
        if ((viewController as! FrameViewController).current) {
            currentIndex = movielist.tableRows.index(of: (viewController as! FrameViewController).movie_info!)!
        }
        else {
            currentIndex = movielist.tableRows.count + uplist.index(of: (viewController as! FrameViewController).up_movie_info!)!
        }
        
        if (currentIndex > 0 && currentIndex < movielist.tableRows.count + 1) {
            let frameVC = FrameViewController()
            frameVC.current = true
            frameVC.movie_info = movielist.tableRows[currentIndex - 1]
            
            print("next movie is \(currentIndex) with name " + (frameVC.movie_info?.title)!)
            print("review \(frameVC.movie_info?.comment_body)")
            //mush: like
            if (user_p?.currentLikedMovie.contains((frameVC.movie_info?.title)!))! {
                print("swipe right:FOUND THE MOVIE IN LIKED LIST")
                frameVC.like = true
            }
            else {
                print("swipe right:NOT LIKED")
            }
            
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            user_p?.currentLikedMovie.removeAll()
            UserProfileToDB().getLikedMovies(userId: AWSIdentityManager.default().identityId!, user_profile: user_p!)
            
            return frameVC
        }
        else if (currentIndex > movielist.tableRows.count) {
            let frameVC = FrameViewController()
            frameVC.current = false
            frameVC.up_movie_info = uplist[currentIndex - movielist.tableRows.count - 1]
        
            print("next movie is \(currentIndex) with name " + (frameVC.up_movie_info?.title)!)
            //mush: like
            if (user_p?.currentLikedMovie.contains((frameVC.up_movie_info?.title)!))! {
                print("swipe right:FOUND THE MOVIE IN LIKED LIST")
                frameVC.like = true
            }
            else {
                print("swipe right:NOT LIKED")
            }
            
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            user_p?.currentLikedMovie.removeAll()
            UserProfileToDB().getLikedMovies(userId: AWSIdentityManager.default().identityId!, user_profile: user_p!)
            
            return frameVC
        }
        return nil
        
    }
    
    // current viewcontroller
    override func viewWillAppear(_ animated: Bool) {
        print("wiew Appear")
        if (isFirstMovieView && AWSIdentityManager.default().isLoggedIn) {
            print("view First appear")
            viewDidLoad()
        }
    }
    
    // Page view functions end here
    // ============================================
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This is each page's view controller
class FrameViewController: UIViewController {
    
    // Loading Indicator
    let loadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 30, y: UIScreen.main.bounds.height/2 - 30, width: 60, height: 60), type: .ballRotateChase, color: UIColor.darkGray, padding: CGFloat(0))
    
    // DB related var
    var user_p = UserProfileToDB()
    var like = false
    var movie_info = SingleMovie()
    var videoURL = ""
    var up_movie_info = UpcomMovie()
    var current = true
    
    // UI var
    let movieTitle = UILabel()
    let movieDetailedInfo = UITextView()
    let videoView : UIWebView = {
        let vd = UIWebView()
        vd.backgroundColor = UIColor.clear
        vd.scrollView.isScrollEnabled = false
        vd.scrollView.bounces = false
        vd.allowsInlineMediaPlayback = true
        
        return vd
    }()
    let movieRelease = UILabel()
    let movieDirector = UILabel()
    let movieContent = UIScrollView(frame: CGRect(x: 0, y: 22, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 46))
    let upcomLabel = UILabel()
    let review_author = UILabel()
    let review_body = UITextView()
    
    // image view init
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 110)
        
        return iv
    }()
    
    // Big Heart image
    let likeImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Liked")
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    // Small Heart button
    let doHeartButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(named: "DoHeart"), for: .normal)
        bt.addTarget(self, action: #selector(FrameViewController.cancelLike), for: .touchUpInside)
        
        return bt
    }()
    
    // ACTIONS:
    // Small heart button action (cancel like)
    func cancelLike() {
        if (current) {
            //remove user from movie's liked list
            SingleMovie().deleteFromCurrentLikedUser(key: movieTitle.text!, userid: AWSIdentityManager.default().identityId!)
        }
        
        //remove movie from user's liked list
        UserProfileToDB().deleteFromCurrentLikedMovie(key: AWSIdentityManager.default().identityId!, movieTitle: movieTitle.text!)
        // unlike animation
        UIView.animate(withDuration: 0.1 / 1.5, animations: {() -> Void in
            self.doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.1 / 2, animations: {() -> Void in
                self.doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1 / 2, animations: {() -> Void in
                    self.doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
                }, completion: {(finished: Bool) in
                    self.doHeartButton.alpha = 0
                    self.doHeartButton.transform = CGAffineTransform.identity
                    self.doHeartButton.removeFromSuperview()
                })
            })
        })
    }
    
    // Double Tap action
    func doubleTapAction() {
        if (current) {
            //add user to movie's liked user list
            SingleMovie().insertToCurrentLikedUser(key: movieTitle.text!, userid: AWSIdentityManager.default().identityId!)
        }
        
        //add movie to user's liked movie list
        UserProfileToDB().insertToCurrentLikedMovie(key: AWSIdentityManager.default().identityId!, movieTitle: movieTitle.text!)
        
        //        imageView.isUserInteractionEnabled = false // in case if the user trying to do multiple double tap in a short time
        let newX = imageView.bounds.width
        let newY = imageView.bounds.height
        likeImage.frame = CGRect(x: newX * 0.4, y: newY * 0.4, width: newX * 0.2, height: newY * 0.2)
        likeImage.alpha = 0.98
        imageView.addSubview(likeImage)
        
        // pop up
        likeImage.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.2 / 1.5, animations: {() -> Void in
            self.likeImage.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.2 / 2, animations: {() -> Void in
                self.likeImage.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.2 / 2, animations: {() -> Void in
                    self.likeImage.transform = CGAffineTransform.identity
                }, completion: {(finished: Bool) in
                    // fade out
                    UIView.animate(withDuration: 0.2, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.likeImage.alpha = 0
                    }, completion: {(finished: Bool) in
                        self.likeImage.removeFromSuperview()
                        //                        self.imageView.isUserInteractionEnabled = true // reenable the double tap
                    })
                })
            })
        })
        
        // do heart button create
        self.doHeartButton.alpha = 1
        doHeartButton.frame = CGRect(x: 10 + movieTitle.frame.width, y: imageView.frame.height + 10, width: 25, height: 25)
        movieContent.addSubview(doHeartButton)
        
        // do heart button animation
        doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.2 / 1.5, animations: {() -> Void in
            self.doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.2 / 2, animations: {() -> Void in
                self.doHeartButton.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.2 / 2, animations: {() -> Void in
                    self.doHeartButton.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        })
        
    }
    
    // ====================================================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading animation
        self.view.addSubview(loadingIndicatorView)
        
        // view changes
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.backgroundColor = UIColor.clear
        //mush
        if (current) {
            movieTitle.text = movie_info?.title
            movieDetailedInfo.text = movie_info?.longDescription
            
            //mush
            //imageView.image = movie_info?.image
            //moviePopInfo.text = movie_info?.pop
            if (movie_info?.poster_path != nil) {
                let path = "https://image.tmdb.org/t/p/w780/" + (movie_info?.poster_path)!
                imageView.loadImageUsingURLString(URLString: path)
                
                videoURL = "https://www.youtube.com/embed/" + (movie_info?.trailer_key!)! + "?rel=0&showinfo=0&autoplay=1"
            }
        }
        else {
            movieTitle.text = up_movie_info?.title
            movieDetailedInfo.text = up_movie_info?.overview
            
            if (up_movie_info?.poster_path != nil) {
                let path = "https://image.tmdb.org/t/p/w780/" + (up_movie_info?.poster_path)!
                imageView.loadImageUsingURLString(URLString: path)
                
                videoURL = "https://www.youtube.com/embed/" + (up_movie_info?.trailer_key!)! + "?rel=0&showinfo=0&autoplay=1"
            }

        }
        
        // add scroll view
        movieContent.showsVerticalScrollIndicator = true
        movieContent.isScrollEnabled = true
        movieContent.isUserInteractionEnabled = true
        movieContent.backgroundColor = UIColor.clear
        
        self.view.addSubview(movieContent)
        //        movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*1.775)
        
        // add image view to scroll view
        if (current) {
            imageView.isUserInteractionEnabled = true
            let doubletap = UITapGestureRecognizer()
            doubletap.numberOfTapsRequired = 2;
            doubletap.addTarget(self, action: #selector(FrameViewController.doubleTapAction))
            imageView.addGestureRecognizer(doubletap)
        }
        
        movieContent.addSubview(imageView)
        
        // add movie title in to the scroll view
        movieTitle.frame = CGRect(x: 10, y: imageView.frame.height + 5, width: UIScreen.main.bounds.width - 50, height: 30)
        movieTitle.font = UIFont(name: "HelveticaNeue-Light", size: 23)
        movieTitle.textColor = UIColor.black
        movieContent.addSubview(movieTitle)
        
        // add movie info in to the scroll view
        movieDetailedInfo.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: 200)
        movieDetailedInfo.font = UIFont(name: "HelveticaNeue-thin", size: 15)
        movieDetailedInfo.textColor = UIColor.black
        movieDetailedInfo.backgroundColor = UIColor.clear
        movieDetailedInfo.isEditable = false
        movieDetailedInfo.sizeToFit()
        movieContent.addSubview(movieDetailedInfo)
        /*
        if (current) {
            // resize the detailed info
            if (movie_info?.longDescription != nil) {
                movieDetailedInfo.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: movieDetailedInfo.contentSize.height)
            }
        }
        else {
            // resize the detailed info
            if (up_movie_info?.overview != nil) {
                movieDetailedInfo.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: movieDetailedInfo.contentSize.height)
            }

        }*/
        // add movie trailer
        let htmlStyle = "<style> iframe { margin: 0px !important; padding: 0px !important; border: 0px !important; } html, body { margin: 0px !important; padding: 0px !important; border: 0px !important; width: 100%; height: 100%; } </style>"
        videoView.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: (UIScreen.main.bounds.width - 15)/1.85)
        videoView.loadHTMLString("<html><head><style>\(htmlStyle)</style></head><body><iframe width='100%' height='100%' src='\(videoURL)' frameborder='0' allowfullscreen></iframe></body></html>", baseURL: nil)
        movieContent.addSubview(videoView)
        
        // add movie release year in to the scroll view
        movieRelease.frame = CGRect(x: 10, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23)
        movieRelease.textColor = UIColor.black
        if (current) {
            if (movie_info?.releaseYear != nil) {
                let strText = NSMutableAttributedString(string: "RELEASE YEAR  " + (movie_info?.releaseYear!)!)
                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 13))
                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 13, length: strText.length - 13))
                movieRelease.attributedText = strText
                
            }

        }
        else {
            if (up_movie_info?.release_date != nil) {
                let strText = NSMutableAttributedString(string: "RELEASE DATE  " + (up_movie_info?.release_date!)!)
                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 13))
                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 13, length: strText.length - 13))
                movieRelease.attributedText = strText
                
            }
        }
        movieContent.addSubview(movieRelease)
        
        
        if (current && (movie_info?.directors != nil)) {
            // add movie director in to the scrool view
            movieDirector.frame = CGRect(x: 10, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23)
            movieDirector.textColor = UIColor.black
            //if (movie_info?.directors != nil) {
                
                
            //}
            let realDirector = movie_info?.directors.joined(separator: ", ")
            let strText1 = NSMutableAttributedString(string: "DIRECTOR  " + realDirector!)
            strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 10))
            strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 10, length: strText1.length - 10))
            movieDirector.attributedText = strText1
        }
        else {
            movieDirector.frame = CGRect(x: 10, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height, width: UIScreen.main.bounds.width - 15, height: 10)
        }
        movieContent.addSubview(movieDirector)

        // add review author in to the scroll view
        if (current && (movie_info?.comment_author != nil)) {
            review_author.frame = CGRect(x: 10, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + movieDirector.frame.height + 10, width: UIScreen.main.bounds.width - 50, height: 30)
            //review_author.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            review_author.textColor = UIColor.black
            review_author.text = "Review: " + (movie_info?.comment_author!)!
            
            let strText = NSMutableAttributedString(string: "Review: " + (movie_info?.comment_author!)!)
            strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 8))
            strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 8, length: strText.length - 8))
            review_author.attributedText = strText
            
            
        }
        else {
            review_author.frame = CGRect(x: 10, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + movieDirector.frame.height + 10, width: UIScreen.main.bounds.width - 50, height: 10)
        }
        movieContent.addSubview(review_author)
        
        if (current && (movie_info?.comment_body != nil)) {
            // add review body in to the scroll view
            review_body.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + movieDirector.frame.height + review_author.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 1000)
            review_body.text = movie_info?.comment_body
            review_body.font = UIFont(name: "HelveticaNeue-thin", size: 15)
            review_body.textColor = UIColor.black
            review_body.backgroundColor = UIColor.clear
            review_body.isEditable = false
            
            
            // resize the detailed info
            review_body.sizeToFit()

        }
        else {
            review_body.frame = CGRect(x: 6, y: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + movieDirector.frame.height + review_author.frame.height, width: UIScreen.main.bounds.width - 15, height: 10)
            review_body.backgroundColor = UIColor.clear
            review_body.isEditable = false

        }
        movieContent.addSubview(review_body)

        
        movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: imageView.frame.height + movieTitle.frame.height + movieDetailedInfo.frame.height + videoView.frame.height + movieRelease.frame.height + review_author.frame.height + movieDirector.frame.height + review_body.frame.height + 200)
        
        
        // add small heart
        if (like) {
            // do heart button create
            self.doHeartButton.alpha = 1
            doHeartButton.frame = CGRect(x: 10 + movieTitle.frame.width, y: imageView.frame.height + 10, width: 25, height: 25)
            movieContent.addSubview(doHeartButton)
        }
        if (!current) {
            upcomLabel.frame = CGRect(x: movieTitle.frame.width, y: imageView.frame.height + 10, width: 50, height: 25)
            //movieTitle.frame = CGRect(x: 10, y: imageView.frame.height + 5, width: UIScreen.main.bounds.width - 50, height: 30)
            upcomLabel.text = "UPCOMING"
            upcomLabel.font = UIFont(name: "HelveticaNeue-Light", size: 8)
            upcomLabel.textColor = UIColor.black
            
            movieContent.addSubview(upcomLabel)
            
        }
    }
}

var picCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingURLString(URLString: String) {
        
        // Loading Indicator
        let imageLoadingIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.bounds.width/2 - 30, y: self.bounds.height/2 - 30, width: 60, height: 60), type: .squareSpin, color: UIColor.init(red: 95/255, green: 95/255, blue: 95/255, alpha: 1), padding: CGFloat(0))
        self.addSubview(imageLoadingIndicatorView)
        self.backgroundColor = UIColor.init(red: 223/255, green: 223/255, blue: 223/255, alpha: 1)
        imageLoadingIndicatorView.startAnimating()
        
        guard let url = URL(string: URLString) else { return }
        
        image = nil
        
        let imageFromCache = picCache.object(forKey: URLString as NSString)
        
        if imageFromCache != nil {
            // Stop loading animation
            imageLoadingIndicatorView.stopAnimating()
            imageLoadingIndicatorView.removeFromSuperview()
            
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                // Stop loading animation
                imageLoadingIndicatorView.stopAnimating()
                imageLoadingIndicatorView.removeFromSuperview()
                
                self.backgroundColor = UIColor.brown
                
                print("Error in loading Image")
                return
            }
            
            DispatchQueue.main.async {
                // Stop loading animation
                imageLoadingIndicatorView.stopAnimating()
                imageLoadingIndicatorView.removeFromSuperview()
                
                let imageToCache = UIImage(data: data!)
                picCache.setObject(imageToCache!, forKey: URLString as NSString)
                self.image = imageToCache
            }
            }.resume()
        
    }
    
}
