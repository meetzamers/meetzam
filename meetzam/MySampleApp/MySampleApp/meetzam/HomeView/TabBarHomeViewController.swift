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
import AWSDynamoDB

class TabBarHomeViewController:  UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    // ============================================
    // Variable starts here
    var new_signinObserver: AnyObject!
    var new_signoutObserver: AnyObject!
    
    var isFirstMovieView = false
    //mush
    var movielist = MovieList()
    var movieView = FrameViewController()
    
    // Variable ends here
    // ============================================
    // Change status bar type to default.
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    // Image Data Source names:
    let imagekeys = ["324849", "313369", "14564", "381288", "346672", "376867", "334543", "334541", "381284", "340666", "369885", "263115", "324552", "283366", "329865", "324786", "341174", "311324"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Let self be the delegate and dataSource
        self.delegate = self
        self.dataSource = self
        SingleMovie().refreshList(movie_list: movielist, view: movieView)
        
        // change background color to grey
        //view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
        // This is the first movie
        if (!AWSIdentityManager.default().isLoggedIn) {
            self.isFirstMovieView = true
        }
        let frameVC = movieView
        //mush
        //let frameVC = FrameViewController()
        //frameVC.imagekey = imagekeys.first
        frameVC.movie_info = movielist.tableRows.first
        print("herer\n")
        print(movielist.tableRows.count)
        
        let viewControllers = [frameVC]
        
        //        let viewControllers = [movieView]
        setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        // ============================================
        // AWS implementation starts here
        // 1. first attempt to pop sign in view controller
        perform(#selector(popSignInViewController), with: nil, afterDelay: 0)
        
        // 2. signinObserver: need to figure it out.
        new_signinObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard let strongSelf = self else { return }
                print("Sign in observer observed sign in.")
        })
        
        // 3. signoutObserver: need to figure it out.
        new_signoutObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AWSIdentityManagerDidSignOut,
            object: AWSIdentityManager.default(),
            queue: OperationQueue.main,
            using: { [weak self] (note: Notification) -> Void in
                guard let strongSelf = self else { return }
                print("Sign Out Observer observed sign out.")
        })
        
        // AWS implementation ends here
        // ============================================
        
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
    
    // AWS support functions end here
    // ============================================
    // Page view functions start here
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        /*
         let currentImageName = (viewController as! FrameViewController).imagekey
         let currentIndex = imagekeys.index(of: currentImageName!)
         
         if (currentIndex! < imagekeys.count - 1) {
         let frameVC = FrameViewController()
         frameVC.imagekey = imagekeys[currentIndex! + 1]
         
         // turn off isFirstMovieView
         self.isFirstMovieView = false
         
         return frameVC
         }
         
         return nil
         */
        
        // Mogu's new stuff
        
        //        if currentIndex + 1 < movielist.tableRows.count {
        //            currentIndex += 1
        //            let frameVC = FrameViewController()
        //            frameVC.setVC(content: movielist.tableRows[currentIndex])
        //            return frameVC
        //        }
        //
        //        return nil
        let currentMovie = (viewController as! FrameViewController).movie_info
        print(movielist.tableRows.count)
        let currentIndex = movielist.tableRows.index(of: currentMovie!)
        
        if (currentIndex! < (movielist.tableRows.count) - 1) {
            let frameVC = FrameViewController()
            frameVC.movie_info = movielist.tableRows[currentIndex! + 1]
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            return frameVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        /*
         let currentImagekey = (viewController as! FrameViewController).imagekey
         let currentIndex = imagekeys.index(of: currentImagekey!)
         
         if (currentIndex! > 0) {
         let frameVC = FrameViewController()
         frameVC.imagekey = imagekeys[currentIndex! - 1]
         
         // turn off isFirstMovieView
         self.isFirstMovieView = false
         
         return frameVC
         }
         
         return nil
         */
        // Mogu's new stuff
        
        //        if currentIndex - 1 < 0 {
        //            currentIndex -= 1
        //            let frameVC = FrameViewController()
        //            frameVC.setVC(content: movielist.tableRows[currentIndex])
        //            return frameVC
        //        }
        //        return nil
        let currentMovie = (viewController as! FrameViewController).movie_info
        let currentIndex = movielist.tableRows.index(of: currentMovie!)
        
        if (currentIndex! > 0) {
            let frameVC = FrameViewController()
            frameVC.movie_info = movielist.tableRows[currentIndex! - 1]
            
            // turn off isFirstMovieView
            self.isFirstMovieView = false
            
            return frameVC
        }
        
        return nil
        
    }
    
    // current viewcontroller
    override func viewWillAppear(_ animated: Bool) {
        if (isFirstMovieView && AWSIdentityManager.default().isLoggedIn) {
            viewDidLoad()
        }
    }
    
    // Page view functions end here
    // ============================================
}

// This is each page's view controller
class FrameViewController: UIViewController {
    
    // UI var
    let movieTitle = UILabel()
    let movieDetailedInfo = UITextView()
    let moviePopInfo = UILabel()
    
    var imagekey: String?
    
    var movie_info = SingleMovie()
    
    // image view init
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 110)
        return iv
    }()
    
    // scoll view
    let movieContent = UIScrollView(frame: CGRect(x: 0, y: 22, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 46))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // view changes
        
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.backgroundColor = UIColor.clear
        //mush
        //SingleMovie().getMovieForDisplay(key: imagekey!, movie_data: movie_info, movieTitle: movieTitle, movieTitleDetailed: movieDetailedInfo, imageView: imageView, moviePopInfo: moviePopInfo)
        movieTitle.text = movie_info?.title
        movieDetailedInfo.text = movie_info?.longDescription
        
        imageView.image = movie_info?.image
        moviePopInfo.text = movie_info?.pop
        
        // add scroll view
        movieContent.showsVerticalScrollIndicator = true
        movieContent.isScrollEnabled = true
        movieContent.isUserInteractionEnabled = true
        movieContent.backgroundColor = UIColor.clear
        self.view.addSubview(movieContent)
        movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*1.3)
        
        // add image view to scroll view
        movieContent.addSubview(imageView)
        
        // add movie title in to the scroll view
        movieTitle.frame = CGRect(x: 10, y: imageView.frame.height + 5, width: UIScreen.main.bounds.width - 20, height: 30)
        movieTitle.font = UIFont(name: "HelveticaNeue-Light", size: 23)
        movieTitle.textColor = UIColor.black
        movieContent.addSubview(movieTitle)
        
        // add movie popularity in to the scroll view
        moviePopInfo.frame = CGRect(x: 10, y: imageView.frame.height + 40, width: UIScreen.main.bounds.width - 20, height: 30)
        moviePopInfo.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        moviePopInfo.textColor = UIColor.black
        moviePopInfo.textAlignment = .right
        movieContent.addSubview(moviePopInfo)
        
        // add movie info in to the scroll view
        movieDetailedInfo.frame = CGRect(x: 5, y: imageView.frame.height + 70, width: UIScreen.main.bounds.width - 15, height: 200)
        movieDetailedInfo.font = UIFont(name: "HelveticaNeue-thin", size: 15)
        movieDetailedInfo.textColor = UIColor.black
        movieDetailedInfo.backgroundColor = UIColor.clear
        movieDetailedInfo.isEditable = false
        movieContent.addSubview(movieDetailedInfo)
    }
    
}
