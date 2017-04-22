//
//  HistoryMovie.swift
//  MySampleApp
//
//  Created by Rainy on 2017/4/1.
//
//

import UIKit
import AWSDynamoDB
import AWSS3
import Foundation
class HistoryMovie: AWSDynamoDBObjectModel, AWSDynamoDBModeling
{
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
    
    class func dynamoDBTableName() -> String {
        return "movie_history"
    }
    
    class func hashKeyAttribute() -> String {
        return "title"
    }
    
    //JUNPU: fixed
    func getAllHistoryMovieTitles() -> [String]
    {
        print("===== getAllHistoryMovies =====")
        var historyMovieTitles: Array = [String]()
        let mapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        
        mapper.scan(HistoryMovie.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let allHistoryMovies = task.result {
                for history_movie in allHistoryMovies.items as! [HistoryMovie] {
                    historyMovieTitles.append(history_movie.title)
                }
            }
            return nil
        }).waitUntilFinished()
        print("getAllHistoryMovies SUCCESS")
        return historyMovieTitles
    }
    
    //JUNPU: fixed
    func getAllLikedMovieTitles(userID: String) -> [String]
    {
        print("===== getAllLikedMovieTitles =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var currentLikedMovie = Set<String>()
        let userProfile = UserProfileToDB()
        mapper.load(UserProfileToDB.self, hashKey: userID, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("InsertError: \(error)")
            } else if let user_profile_addTo = task.result as? UserProfileToDB {
                if (user_profile_addTo.currentLikedMovie.count != 0 && user_profile_addTo.movieCount == 0) {
                    print("dummy detected")
                }
                else {
                    currentLikedMovie=user_profile_addTo.currentLikedMovie
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return nil
        }).waitUntilFinished()

        var allLikedMovieTitles: Array = [String]()
        for movie in currentLikedMovie
        {
            allLikedMovieTitles.append(movie)
        }
        print("getAllLikedMovieTitles SUCCESS")
        return allLikedMovieTitles
    }
    
    
    //JUNPU: fixed
    func userLikedHistoryMovies(_userID: String) -> [HistoryMovie]
    {
        print("===== userLikedHistoryMovies =====")
        var historyTitles: Array = [String]()
        var historyResult: Array = [HistoryMovie]()
        let mapper = AWSDynamoDBObjectMapper.default()
        let all_history_titles = HistoryMovie().getAllHistoryMovieTitles()
        let all_liked_titles = HistoryMovie().getAllLikedMovieTitles(userID: _userID)
        for movie_title in all_liked_titles
        {
            if (all_history_titles.contains(movie_title))
            {
                historyTitles.append(movie_title)
            }
        }
        for history_title in historyTitles
        {
            mapper.load(HistoryMovie.self, hashKey: history_title, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("InsertError: \(error)")
                } else if let history_movie = task.result as? HistoryMovie {
                    historyResult.append(history_movie)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return nil
            }).waitUntilFinished()

        }
        print("userLikedHistoryMovies SUCCESS")
        return historyResult
    }
}
