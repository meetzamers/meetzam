//
//  MovieAndList.swift
//  MySampleApp
//
//  Created by Ling Zhang on 3/22/17.
//
//


import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

let AWSDynamoDBTableName = "movie_table"//"meetzam-mobilehub-1569925313-Movie"
class SingleMovie : AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    //var movie_id: Int?
    
    var title = String()
    var directors = Set<String>()
    var genres = Set<String>()
    var longDescription: String?
    var poster_path: String?
    var releaseYear: String?
    var shortDescriptiontle: String?
    var tmdb_id: String?
    var topCast = Set<String>()
    var trailer_key: String?
    var currentLikedUser = Set<String>()
    var userCount: NSNumber?
    var comment_author: String?
    var comment_body: String?
    
    
    //var image: UIImage?
    //var pop: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "title"
    }
    
    func refreshList(movie_list: MovieList, view: FrameViewController, user_profile: UserProfileToDB)  {
        print("===== refreshList =====")
        // Loading Animations
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        view.loadingIndicatorView.startAnimating()
        view.view.backgroundColor = UIColor.white
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        // queryExpression.exclusiveStartKey = self.lastEvaluatedKey
        //queryExpression.limit = 5
        
        dynamoDBObjectMapper.scan(SingleMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            var c = 0
            
            if let paginatedOutput = task.result {
                for item in paginatedOutput.items as! [SingleMovie] {
                    movie_list.tableRows.append(item)
                    
                    if c == 0 {
                        
                        if (user_profile.currentLikedMovie.contains(item.title)) {
                            print("scan:FOUND THE MOVIE IN LIKED LIST")
                            view.like = true
                            // do heart button create
                            view.doHeartButton.alpha = 1
                            view.doHeartButton.frame = CGRect(x: 10 + view.movieTitle.frame.width, y: view.imageView.frame.height + 10, width: 25, height: 25)
                            view.movieContent.addSubview(view.doHeartButton)
                        }
                        else {
                            print("scan:NOT LIKED")
                        }
                        view.current = true
                        // view changes
                        view.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        view.view.backgroundColor = UIColor.clear
                        //mush
                        view.movieTitle.text = item.title
                        view.movieDetailedInfo.text = item.longDescription
                        
                        //mush
                        //imageView.image = movie_info?.image
                        //moviePopInfo.text = movie_info?.pop
                        if (item.poster_path != nil) {
                            let path = "https://image.tmdb.org/t/p/w780/" + (item.poster_path)!
                            view.imageView.loadImageUsingURLString(URLString: path)
                            
                            view.videoURL = "https://www.youtube.com/embed/" + (item.trailer_key!) + "?rel=0&showinfo=0&autoplay=1"
                        }
                        
                        
                        // add scroll view
                        view.movieContent.showsVerticalScrollIndicator = true
                        view.movieContent.isScrollEnabled = true
                        view.movieContent.isUserInteractionEnabled = true
                        view.movieContent.backgroundColor = UIColor.clear
                        
                        view.view.addSubview(view.movieContent)
                        //        movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*1.775)
                        
                        // add image view to scroll view
                        if (view.current) {
                            view.imageView.isUserInteractionEnabled = true
                            let doubletap = UITapGestureRecognizer()
                            doubletap.numberOfTapsRequired = 2;
                            doubletap.addTarget(self, action: #selector(FrameViewController.doubleTapAction))
                            view.imageView.addGestureRecognizer(doubletap)
                        }
                        
                        view.movieContent.addSubview(view.imageView)
                        
                        // add movie title in to the scroll view
                        view.movieTitle.frame = CGRect(x: 10, y: view.imageView.frame.height + 5, width: UIScreen.main.bounds.width - 50, height: 30)
                        view.movieTitle.font = UIFont(name: "HelveticaNeue-Light", size: 23)
                        view.movieTitle.textColor = UIColor.black
                        view.movieContent.addSubview(view.movieTitle)
                        
                        // add movie info in to the scroll view
                        view.movieDetailedInfo.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: 200)
                        view.movieDetailedInfo.font = UIFont(name: "HelveticaNeue-thin", size: 15)
                        view.movieDetailedInfo.textColor = UIColor.black
                        view.movieDetailedInfo.backgroundColor = UIColor.clear
                        view.movieDetailedInfo.isEditable = false
                        view.movieDetailedInfo.sizeToFit()
                        view.movieContent.addSubview(view.movieDetailedInfo)
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
                        view.videoView.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: (UIScreen.main.bounds.width - 15)/1.85)
                        view.videoView.loadHTMLString("<html><head><style>\(htmlStyle)</style></head><body><iframe width='100%' height='100%' src='\(view.videoURL)' frameborder='0' allowfullscreen></iframe></body></html>", baseURL: nil)
                        view.movieContent.addSubview(view.videoView)
                        
                        // add movie release year in to the scroll view
                        view.movieRelease.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23)
                        view.movieRelease.textColor = UIColor.black
                        if (view.current) {
                            if (item.releaseYear != nil) {
                                let strText = NSMutableAttributedString(string: "RELEASE YEAR  " + (item.releaseYear!))
                                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 13))
                                strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 13, length: strText.length - 13))
                                view.movieRelease.attributedText = strText
                                
                            }
                            
                        }
                        view.movieContent.addSubview(view.movieRelease)
                        
                        
                        if (view.current ) {
                            // add movie director in to the scrool view
                            view.movieDirector.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23)
                            view.movieDirector.textColor = UIColor.black
                            //if (movie_info?.directors != nil) {
                            
                            
                            //}
                            let realDirector = item.directors.joined(separator: ", ")
                            let strText1 = NSMutableAttributedString(string: "DIRECTOR  " + realDirector)
                            strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 10))
                            strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 10, length: strText1.length - 10))
                            view.movieDirector.attributedText = strText1
                        }
                        else {
                            view.movieDirector.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height, width: UIScreen.main.bounds.width - 15, height: 10)
                        }
                        view.movieContent.addSubview(view.movieDirector)
                        
                        // add review author in to the scroll view
                        if (view.current && (item.comment_author != nil)) {
                            view.review_author.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.movieDirector.frame.height + 10, width: UIScreen.main.bounds.width - 50, height: 30)
                            //review_author.font = UIFont(name: "HelveticaNeue-Light", size: 15)
                            view.review_author.textColor = UIColor.black
                            view.review_author.text = "Review: " + (item.comment_author!)
                            
                            let strText = NSMutableAttributedString(string: "Review: " + (item.comment_author!))
                            strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 8))
                            strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 8, length: strText.length - 8))
                            view.review_author.attributedText = strText
                            
                            
                        }
                        else {
                            view.review_author.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.movieDirector.frame.height + 10, width: UIScreen.main.bounds.width - 50, height: 10)
                        }
                        view.movieContent.addSubview(view.review_author)
                        
                        if (view.current && (item.comment_body != nil)) {
                            // add review body in to the scroll view
                            view.review_body.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.movieDirector.frame.height + view.review_author.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 1000)
                            view.review_body.text = item.comment_body
                            view.review_body.font = UIFont(name: "HelveticaNeue-thin", size: 15)
                            view.review_body.textColor = UIColor.black
                            view.review_body.backgroundColor = UIColor.clear
                            view.review_body.isEditable = false
                            
                            
                            // resize the detailed info
                            view.review_body.sizeToFit()
                            
                        }
                        else {
                            view.review_body.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.movieDirector.frame.height + view.review_author.frame.height, width: UIScreen.main.bounds.width - 15, height: 10)
                            view.review_body.backgroundColor = UIColor.clear
                            view.review_body.isEditable = false
                            
                        }
                        view.movieContent.addSubview(view.review_body)
                        
                        
                        view.movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.review_author.frame.height + view.movieDirector.frame.height + view.review_body.frame.height + 200)
                        

                        view.movie_info = item;
 
                    }
                    
                    print(movie_list.tableRows.count)
                    print(movie_list.tableRows[c].title)
                    if c > 0 {
                        print(movie_list.tableRows[c - 1].title )
                    }
                    c = c + 1
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
            print("number of all movies \(c)")
            
            // Stop loading animation
            view.loadingIndicatorView.stopAnimating()
            view.loadingIndicatorView.removeFromSuperview()
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                view.view.backgroundColor = UIColor.clear
            })
            print("SUCCESS")
            return nil
        })
    }
    
    //JUNPU: fixed
    func getLikedMoviePosters(key: String) -> [String]
    {
        print("===== getLikedMoviePosters =====")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let mapper = AWSDynamoDBObjectMapper.default()
        var currentLikedMovie = Set<String>()
        let userProfile = UserProfileToDB()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                if (user_profile_addTo.currentLikedMovie.count != 0 && user_profile_addTo.movieCount == 0) {
                    print("dummy detected")
                }
                else {
                    currentLikedMovie=user_profile_addTo.currentLikedMovie
                }
                userProfile?.displayName=user_profile_addTo.displayName
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        }).waitUntilFinished()
        
        var MoviesPosterURL:Array = [String]()
        for movie in (currentLikedMovie) {
            print("You Liked \(movie)")
            mapper.load(SingleMovie.self, hashKey: movie, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("InsertError: \(error)")
                } else if let single_movie = task.result as? SingleMovie {
                    MoviesPosterURL.append(single_movie.poster_path!)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return nil
            }).waitUntilFinished()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return MoviesPosterURL
    }
    
    //JUNPU: fixed
    func getCurrentLikedMovies(key: String) -> [SingleMovie]
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("===== getCurrentLikedMovies =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var currentLikedMovie = Set<String>()
        let userProfile = UserProfileToDB()
        
        mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                if (user_profile_addTo.currentLikedMovie.count != 0 && user_profile_addTo.movieCount == 0) {
                    print("dummy detected")
                }
                else {
                    currentLikedMovie=user_profile_addTo.currentLikedMovie
                }
                userProfile?.displayName=user_profile_addTo.displayName
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        }).waitUntilFinished()
    
        var currentLikedMoviesArr:Array = [SingleMovie]()
        for movie in (currentLikedMovie) {
            print("You Liked \(movie)")
            mapper.load(SingleMovie.self, hashKey: movie, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("InsertError: \(error)")
                } else if let single_movie = task.result as? SingleMovie {
                    currentLikedMoviesArr.append(single_movie)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return nil
            }).waitUntilFinished()

        }
    
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return currentLikedMoviesArr
    }
    
    //JUNPU: fixed
    func isCurrentMovie(title: String) -> Bool
    {
        print("===== isCurrentMovie =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var result: Bool = false
        var currentMovieTitles: Array = [String]()
        let mapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        
        mapper.scan(SingleMovie.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let allCurrentMovie = task.result {
                for current_movie in allCurrentMovie.items as! [SingleMovie] {
                    currentMovieTitles.append(current_movie.title)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        }).waitUntilFinished()
        if (currentMovieTitles.contains(title))
        {
            result = true
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return result
    }
    
    //JUNPU: fixed busy waiting
    func insertToCurrentLikedUser(key: String, userid: String)
    {
        print("===== insertToCurrentLikedUser =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let movie = SingleMovie()
        
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("InsertError: \(error)")
            } else if let movie_addTo = task.result as? SingleMovie {
                
                movie?.title=key
                movie?.directors = movie_addTo.directors
                movie?.genres = movie_addTo.genres
                movie?.longDescription = movie_addTo.longDescription
                movie?.poster_path = movie_addTo.poster_path
                movie?.releaseYear = movie_addTo.releaseYear
                movie?.shortDescriptiontle = movie_addTo.shortDescriptiontle
                movie?.tmdb_id = movie_addTo.tmdb_id
                movie?.topCast = movie_addTo.topCast
                movie?.currentLikedUser = movie_addTo.currentLikedUser
                movie?.userCount = movie_addTo.userCount
                movie?.trailer_key = movie_addTo.trailer_key
                if (!((movie?.currentLikedUser.contains(userid))!))
                {
                    if (movie?.currentLikedUser.count != 0 && movie?.userCount == 0) {
                        //dummy detected
                        movie?.currentLikedUser.removeAll()
                    }
                    movie?.currentLikedUser.insert(userid)
                    movie?.userCount = movie?.currentLikedUser.count as NSNumber?
                }
                mapper.save(movie!)
                print("insertToCurrentLikedUser SUCCESS")
                
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }
    
    //JUNPU: fixed busy waiting
    func deleteFromCurrentLikedUser(key: String, userid: String)
    {
        print("===== deleteFromCurrentLikedUser =====")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let movie = SingleMovie()
        
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("InsertError: \(error)")
            } else if let movie_addTo = task.result as? SingleMovie {
                
                movie?.title=key
                movie?.directors = movie_addTo.directors
                movie?.genres = movie_addTo.genres
                movie?.longDescription = movie_addTo.longDescription
                movie?.poster_path = movie_addTo.poster_path
                movie?.releaseYear = movie_addTo.releaseYear
                movie?.shortDescriptiontle = movie_addTo.shortDescriptiontle
                movie?.tmdb_id = movie_addTo.tmdb_id
                movie?.topCast = movie_addTo.topCast
                movie?.currentLikedUser = movie_addTo.currentLikedUser
                movie?.userCount = movie_addTo.userCount
                movie?.trailer_key = movie_addTo.trailer_key
                if ((movie?.currentLikedUser.contains(userid))!)
                {
                    _ = movie?.currentLikedUser.remove(userid)
                    movie?.userCount = movie?.currentLikedUser.count as NSNumber?
                    //dummy string since empty string set not allowed
                    if (movie?.currentLikedUser.count == 0) {
                        movie?.currentLikedUser.insert("mushroom13")
                    }
                }
                else {
                    print("error: remove a user that is not in the list")
                }
                mapper.save(movie!)
                print("SUCCESS")
                
            }
            return nil
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

class MovieList {
    var tableRows:Array = [SingleMovie]()
    
    
}
