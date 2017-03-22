//
//  MovieFromDB.swift
//  MySampleApp
//
//  Created by Ling Zhang on 2/27/17.
//
//

import Foundation
import AWSDynamoDB

let AWSDynamoDBTableName = "Movie2"//"arn:aws:dynamodb:us-east-1:397508666882:table/Movie2"
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
    func refreshList(movie_list: MovieList, view: FrameViewController)  {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        // queryExpression.exclusiveStartKey = self.lastEvaluatedKey
        //queryExpression.limit = 5
        
        dynamoDBObjectMapper.scan(SingleMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            var c = 0
            var i = 0
            if let paginatedOutput = task.result {
                //let count = paginatedOutput.count as Int
                for item in paginatedOutput.items as! [SingleMovie] {
                /*while i < paginatedOutput.items.count {
                    var item = SingleMovie()
                    
                    item = paginatedOutput.items[i].copy() as! SingleMovie
                    i += 1
                    */
                    if item.TMDB_movie_id == nil || item.Title == nil {
                        continue
                    }

                    movie_list.tableRows.append(item)
                    if c == 0 {
                        view.movieTitle.text = item.Title
                        view.movieDetailedInfo.text = item.overview
                        let path = "https://image.tmdb.org/t/p/w500/" + (item.poster_path)!
                        let imageURL = URL(string: path)
                        let imageData = try! Data(contentsOf: imageURL!)
                        view.imageView.image = UIImage(data: imageData)
                    }
                    
                    print(movie_list.tableRows.count)
                    print(movie_list.tableRows[c].Title)
                    if c > 0 {
                        print(movie_list.tableRows[c - 1].Title)
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
            
            return nil
        })
        
    }
    
}

class MovieList {
    var tableRows:Array = [SingleMovie]()


}
