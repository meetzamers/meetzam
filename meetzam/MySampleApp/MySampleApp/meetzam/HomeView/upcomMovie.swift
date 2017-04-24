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

}
