//
//  upcomMovie.swift
//  MySampleApp
//
//  Created by Ling Zhang on 3/22/17.
//
//


import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

class UpcomMovie : AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {

    
    var title = String()
    //var directors = Set<String>()
    //var genres = Set<String>()
    var overview: String?
    var poster_path: String?
    var release_date: String?
    //var shortDescriptiontle: String?
    var tmdb_id: String?
    //var topCast = Set<String>()
    var trailer_key: String?
    var currentLikedUser = Set<String>()
    //var userCount: NSNumber?
    
    
    //var image: UIImage?
    //var pop: String?
    
    class func dynamoDBTableName() -> String {
        return "movie_upcoming"
    }
    
    class func hashKeyAttribute() -> String {
        return "title"
    }
    
    func upcomList() -> [UpcomMovie] {
        print("===== upcomList =====")
        // Loading Animations
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //view.loadingIndicatorView.startAnimating()
        //view.view.backgroundColor = UIColor.white
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        
        var upcoms = [UpcomMovie]()
        dynamoDBObjectMapper.scan(UpcomMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            /*
            if let paginatedOutput = task.result {
                for item in paginatedOutput.items as! [UpcomMovie] {
                    upcoms.append(item)
                    
                    print(item.description)
                }
            }*/
            upcoms = task.result?.items as! [UpcomMovie]
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
          
            return nil
        }).waitUntilFinished()
        print("number of upcomMovie got \(upcoms.count)")
        return upcoms
        
    }
    
    /*
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
    
*/
}
