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
    //var TMDB_popularity: String?
    var trailer_key: String?
    var currentLikedUser = Set<String>()
    var userCount: NSNumber?
    

    //var image: UIImage?
    //var pop: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "title"
    }
    
/*
    func getMovieForDisplay(key: String, movie_data: SingleMovie?, movieTitle: UILabel!, movieTitleDetailed: UITextView!, imageView: UIImageView!, moviePopInfo: UILabel!){
        print("     enter func getmovieForDisplay")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let mapper = AWSDynamoDBObjectMapper.default()
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            }
            else if let movie_data = task.result as? SingleMovie {
                //print("     Getting fields")
                movieTitle.text = movie_data.Title
                //print(movieTitle.text)
                movieTitleDetailed.text = movie_data.overview
                //print(movieTitleDetailed.text)
                //imgName = URL("https://image.tmdb.org/t/p/w500/" + movie_data.poster_path)
                let path = "https://image.tmdb.org/t/p/w500/" + movie_data.poster_path!
                let imageURL = URL(string: path)
                let imageData = try! Data(contentsOf: imageURL!)
                imageView.image = UIImage(data: imageData)
                
                moviePopInfo.text = "Popularity: " + movie_data.TMDB_popularity!
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
    }
 */
    func refreshList(movie_list: MovieList, view: FrameViewController, user_profile: UserProfileToDB)  {
        
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
                    /*
                    let path = "https://image.tmdb.org/t/p/w500/" + (item.poster_path)!
                    let imageURL = URL(string: path)
                    let imageData = try! Data(contentsOf: imageURL!)
                    item.image = UIImage(data: imageData)
                    
                    print("++++++++++++++++++++++++++++++++++++++++++")
                    print()
                    
                    //item.pop = "Popularity: " + item.TMDB_popularity!
                    */
                    movie_list.tableRows.append(item)
                    
                    if c == 0 {
                        print("LALALA")
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
 
                        view.movieTitle.text = item.title
                        view.movieDetailedInfo.text = item.longDescription
                        view.movieDetailedInfo.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: view.movieDetailedInfo.contentSize.height) // resize the detailed info
                        
                        let path = "https://image.tmdb.org/t/p/w500/" + (item.poster_path)!
                        let imageURL = URL(string: path)
                        let imageData = try! Data(contentsOf: imageURL!)
                        view.imageView.image = UIImage(data: imageData)
                        
                        
                        view.videoURL = "https://www.youtube.com/embed/" + item.trailer_key! + "?rel=0&showinfo=0&autoplay=1"
                        // add movie trailer
                        let htmlStyle = "<style> iframe { margin: 0px !important; padding: 0px !important; border: 0px !important; } html, body { margin: 0px !important; padding: 0px !important; border: 0px !important; width: 100%; height: 100%; } </style>"
                        view.videoView.frame = CGRect(x: 6, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + 5, width: UIScreen.main.bounds.width - 15, height: (UIScreen.main.bounds.width - 15)/1.85)
                        view.videoView.loadHTMLString("<html><head><style>\(htmlStyle)</style></head><body><iframe width='100%' height='100%' src='\(view.videoURL)' frameborder='0' allowfullscreen></iframe></body></html>", baseURL: nil)
                        view.movieContent.addSubview(view.videoView)
                        
                        view.movieRelease.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23) // reposition
                        let strText = NSMutableAttributedString(string: "Release Year: " + item.releaseYear!)
                        strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 13))
                        strText.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 13, length: strText.length - 13))
                        view.movieRelease.attributedText = strText
                        
                        view.movieDirector.frame = CGRect(x: 10, y: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + 10, width: UIScreen.main.bounds.width - 15, height: 23) // reposition
                        let realDirector = item.directors.joined(separator: ", ")
                        let strText1 = NSMutableAttributedString(string: "Director: " + realDirector)
                        strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 15)!, range: NSRange(location: 0, length: 10))
                        strText1.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Thin", size: 15)!, range: NSRange(location: 10, length: strText1.length - 10))
                        view.movieDirector.attributedText = strText1
                        
                        view.movieContent.contentSize = CGSize(width: UIScreen.main.bounds.width, height: view.imageView.frame.height + view.movieTitle.frame.height + view.movieDetailedInfo.frame.height + view.videoView.frame.height + view.movieRelease.frame.height + view.movieDirector.frame.height + 200) // resize the scroll view
                        
                        view.movie_info = item;
                    }
                    
                    print(movie_list.tableRows.count)
                    print(movie_list.tableRows[c].title ?? "mushroom_title")
                    print(movie_list.tableRows[c].topCast.description )
                    if c > 0 {
                        print(movie_list.tableRows[c - 1].title ?? "mushroom_prev_title")
                    }
                    c = c + 1
                    
                }
                
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            if let error = task.error as? NSError {
                print("Error: \(error)")
            }
            print("number of all movies \(c)")
            
            // Stop loading animation
            view.loadingIndicatorView.stopAnimating()
            view.loadingIndicatorView.removeFromSuperview()
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                view.view.backgroundColor = UIColor.clear
            })
            return nil
        })
        
    }
    
    func getLikedMoviePosters(key: String) -> [String]
    {
        print("     getLikedMoviePosters")
        let mapper = AWSDynamoDBObjectMapper.default()
        var currentLikedMovie = Set<String>()
        let userProfile = UserProfileToDB()
        
        print("     before load!!")
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
        })
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        while (userProfile?.displayName==nil)
        {
            print("waiting")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
            })
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        while ((MoviesPosterURL.count) != (currentLikedMovie.count))
        {
            print("waiting")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        return MoviesPosterURL
    }
    
    func insertToCurrentLikedUser(key: String, userid: String)
    {
        print("     ADD USER TO MOVIE")
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let movie = SingleMovie()
        
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let movie_addTo = task.result as? SingleMovie {
                
                movie?.title=key
                print("     key:title is \(key)")
                
                movie?.directors = movie_addTo.directors
                print("directors are \(movie?.directors.description)")
                
                movie?.genres = movie_addTo.genres
                print("genres are \(movie?.genres.description)")
                
                movie?.longDescription = movie_addTo.longDescription
                print("longDescription is \(movie?.longDescription)")
                
                movie?.poster_path = movie_addTo.poster_path
                print("poster_path is \(movie?.poster_path)")
                
                movie?.releaseYear = movie_addTo.releaseYear
                print("releaseYear is \(movie?.releaseYear)")
                
                movie?.shortDescriptiontle = movie_addTo.shortDescriptiontle
                print("shortDescriptiontle is \(movie?.shortDescriptiontle)")
                
                movie?.tmdb_id = movie_addTo.tmdb_id
                print("tmdb_id is \(movie?.tmdb_id)")
                
                movie?.topCast = movie_addTo.topCast
                print("topCast are \(movie?.topCast.description)")
                
                movie?.currentLikedUser = movie_addTo.currentLikedUser
                print("BEFORE INSERTING: currentLikedUser are \(movie?.currentLikedUser.description)")
                
                movie?.userCount = movie_addTo.userCount
                
                movie?.trailer_key = movie_addTo.trailer_key
                print("trailer_key is \(movie?.trailer_key)")
                
                print("     all put")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
        while(movie?.trailer_key==nil)
        {
            print("waiting")
        }
        print("SHOULD BE AFTER LOAD: title and id are \(movie?.title) and \(movie?.tmdb_id)")
        if (!((movie?.currentLikedUser.contains(userid))!))
        {
            if (movie?.currentLikedUser.count != 0 && movie?.userCount == 0) {
                //dummy detected
                movie?.currentLikedUser.removeAll()
            }
            movie?.currentLikedUser.insert(userid)
            movie?.userCount = movie?.currentLikedUser.count as NSNumber?
        }
        print("AFTER INSERTING: currentLikedUser are \(movie?.currentLikedUser.description)")
        mapper.save(movie!)
    }
    
    func deleteFromCurrentLikedUser(key: String, userid: String)
    {
        print("     ADD USER TO MOVIE")
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let movie = SingleMovie()
        
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let movie_addTo = task.result as? SingleMovie {
                
                movie?.title=key
                print("     key:title is \(key)")
                
                movie?.directors = movie_addTo.directors
                print("directors are \(movie?.directors.description)")
                
                movie?.genres = movie_addTo.genres
                print("genres are \(movie?.genres.description)")
                
                movie?.longDescription = movie_addTo.longDescription
                print("longDescription is \(movie?.longDescription)")
                
                movie?.poster_path = movie_addTo.poster_path
                print("poster_path is \(movie?.poster_path)")
                
                movie?.releaseYear = movie_addTo.releaseYear
                print("releaseYear is \(movie?.releaseYear)")
                
                movie?.shortDescriptiontle = movie_addTo.shortDescriptiontle
                print("shortDescriptiontle is \(movie?.shortDescriptiontle)")
                
                movie?.tmdb_id = movie_addTo.tmdb_id
                print("tmdb_id is \(movie?.tmdb_id)")
                
                movie?.topCast = movie_addTo.topCast
                print("topCast are \(movie?.topCast.description)")
                
                movie?.currentLikedUser = movie_addTo.currentLikedUser
                print("BEFORE DELETION: currentLikedUser are \(movie?.currentLikedUser.description)")
                
                movie?.userCount = movie_addTo.userCount
                
                movie?.trailer_key = movie_addTo.trailer_key
                print("trailer_key is \(movie?.trailer_key)")
                
                print("     all put")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        })
        while(movie?.trailer_key==nil)
        {
            print("waiting")
        }
        print("SHOULD BE AFTER LOAD: title and id are \(movie?.title) and \(movie?.tmdb_id)")
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
        print("AFTER DELETION: currentLikedUser are \(movie?.currentLikedUser.description)")
        mapper.save(movie!)
    }
}

class MovieList {
    var tableRows:Array = [SingleMovie]()
    
    
}
