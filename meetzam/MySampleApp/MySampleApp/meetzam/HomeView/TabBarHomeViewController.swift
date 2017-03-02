//
//  TabBarHomeViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/20/17.
//
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

//class TabBarHomeViewController: UIViewController {
class TabBarHomeViewController:  UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    // ============================================
    // Variable starts here
    var new_signinObserver: AnyObject!
    var new_signoutObserver: AnyObject!
    // Variable ends here
    // ============================================
    // Change status bar type to default.
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    // Image Data Source names:
    let imageNames = ["loganposter2", "John", "split", "lala"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Let self be the delegate and dataSource
        self.delegate = self
        self.dataSource = self
        
        // change background color to grey
        view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        let frameVC = FrameViewController()
        frameVC.imgName = imageNames.first
        
        let viewControllers = [frameVC]
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
        if (!AWSIdentityManager.default().isLoggedIn) {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignIn")

            self.present(viewController, animated: false, completion: nil)

        }
    }
    // AWS support functions end here
    // ============================================
    // Page view functions start here
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentImageName = (viewController as! FrameViewController).imgName
        let currentIndex = imageNames.index(of: currentImageName!)
        
        if (currentIndex! < imageNames.count - 1) {
            let frameVC = FrameViewController()
            frameVC.imgName = imageNames[currentIndex! + 1]
            
            return frameVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentImageName = (viewController as! FrameViewController).imgName
        let currentIndex = imageNames.index(of: currentImageName!)
        
        if (currentIndex! > 0) {
            let frameVC = FrameViewController()
            frameVC.imgName = imageNames[currentIndex! - 1]
            
            return frameVC
        }
        
        return nil
    }
    
    // Page view functions end here
    // ============================================
}

// This is each page's view controller
class FrameViewController: UIViewController {
    
    // string for the image view
    var imgName: String? {
        didSet {
            imageView.image = UIImage(named: imgName!)
        }
    }
    
    // image view init
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100)
        return iv
    }()
    
    // scoll view
    let movieContent = UIScrollView(frame: CGRect(x: 0, y:22, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 46))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // view changes
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.backgroundColor = UIColor.clear
        
        // add scroll view
        movieContent.showsVerticalScrollIndicator = true
        movieContent.isScrollEnabled = true
        movieContent.isUserInteractionEnabled = true
        self.view.addSubview(movieContent)
        movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*2)
        
        // add image view to scroll view
        movieContent.addSubview(imageView)
        
        // add movie content in to the scroll view
        let movieTitle = UILabel(frame: CGRect(x: 10, y: imageView.frame.height, width: UIScreen.main.bounds.width/2 - 10, height: 30))
        movieTitle.font = UIFont(name: "HelveticaNeue-Light", size: 23)
        movieTitle.text = "Logan"
        //movieTitle.adjustsFontSizeToFitWidth = true
        movieTitle.textColor = UIColor.black
        movieContent.addSubview(movieTitle)
        
        let movieTitleDetailed = UILabel(frame: CGRect(x: UIScreen.main.bounds.width/2 - 10, y: imageView.frame.height, width: UIScreen.main.bounds.width/2 - 10, height: 30))
        movieTitleDetailed.font = UIFont(name: "HelveticaNeue-thin", size: 13)
        movieTitleDetailed.text = "Science fiction film/Drama film | 2h 21m"
        movieTitleDetailed.textColor = UIColor.black
        movieContent.addSubview(movieTitleDetailed)
    }
}
