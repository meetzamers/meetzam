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
    
    func getAllHistoryMovies() -> [HistoryMovie]
    {
        print("     getAllHistoryMovies")
        var historyMovies: Array = [HistoryMovie]()
        let mapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        var dummynum: Int = 0
        
        mapper.scan(HistoryMovie.self, expression: scanExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let allHistoryMovies = task.result {
                for history_movie in allHistoryMovies.items as! [HistoryMovie] {
                    historyMovies.append(history_movie)
                }
                dummynum = 6
            }
            return nil
        })
        while (dummynum != 6)
        {
            print("getAllHistoryMovies waiting")
        }
        return historyMovies
    }
    
    // pass SingleMovie().getAllLikedMovies as "userLikedMovies"
    // pass HistoryMovie().getAllHistoryMovies as "historyMovies"
    func userLikedHistoryMovies(userLikedMovies: [SingleMovie], historyMovies: [HistoryMovie]) -> [HistoryMovie]
    {
        print("     userLikedHistoryMovies")
        var historyResult: Array = [HistoryMovie]()
        let mapper = AWSDynamoDBObjectMapper.default()
        var dummynum: Int = 0
        
        for likedMovie in userLikedMovies
        {
            dummynum = 0
            mapper.load(HistoryMovie.self, hashKey: likedMovie, rangeKey: nil) .continueWith(executor: AWSExecutor.immediate(), block: { (task: AWSTask!) -> AnyObject! in
                if let error = task.error as? NSError {
                    print("Error: \(error)")
                } else if let likedMovie = task.result as? HistoryMovie {
                    if (historyMovies.contains(likedMovie))
                    {
                        historyResult.append(likedMovie)
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                dummynum = 6
                return nil
            })
            while (dummynum != 6)
            {
                print("userLikedHistoryMovies waiting")
            }
        }
        return historyResult
    }
}
