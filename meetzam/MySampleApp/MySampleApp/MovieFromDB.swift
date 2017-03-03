//
//  MovieFromDB.swift
//  MySampleApp
//
//  Created by Ling Zhang on 2/27/17.
//
//

import Foundation
import AWSDynamoDB

let AWSDynamoDBTableName = "Movie2"//"meetzam-mobilehub-1569925313-Movie"
class SingleMovie : AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    var movie_id: Int?
    var TMDB_movie_id: String?
    var Title: String?
    var TMDB_popularity: String?
    var release_date: String?
    var poster_path: String?
    var overview: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "TMDB_movie_id"
    }
    
    
    func getMovieForDisplay(key: String, movie_data: SingleMovie?, movieTitle: UILabel!, movieTitleDetailed: UITextView!, imageView: UIImageView!, moviePopInfo: UILabel!){
        print("     enter func getmovieForDisplay")
        /*let mapper = AWSDynamoDBObjectMapper.default()
         return mapper.load(UserProfileToDB.self, hashKey: key, rangeKey: email)*/
        let mapper = AWSDynamoDBObjectMapper.default()
        
        //print("userId is ", user_profile?.userId, separator: " ")
        //tableRow?.UserId --> (tableRow?.UserId)!
        mapper.load(SingleMovie.self, hashKey: key, rangeKey: nil) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            } else if let movie_data = task.result as? SingleMovie {
                print("     Getting fields")
                movieTitle.text = movie_data.Title
                print(movieTitle.text)
                movieTitleDetailed.text = movie_data.overview
                print(movieTitleDetailed.text)
                //imgName = URL("https://image.tmdb.org/t/p/w500/" + movie_data.poster_path)
                let path = "https://image.tmdb.org/t/p/w500/" + movie_data.poster_path!
                let imageURL = URL(string: path)
                let imageData = try! Data(contentsOf: imageURL!)
                imageView.image = UIImage(data: imageData)
                
                moviePopInfo.text = "Popularity: " + movie_data.TMDB_popularity!
                
            }
            
            return nil
        })
    }
}
