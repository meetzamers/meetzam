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
    var TMDB_movie_id: String?
    var Title: String?
    var TMDB_popularity: String?
    var release_date: String?
    var poster_path: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "TMDB_popularity"
    }
    
}

class MovieList {
    var tableRows:Array<SingleMovie>?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var  doneLoading = false
    
    func refreshList(_ startFromBeginning: Bool)  {
        if startFromBeginning {
            self.lastEvaluatedKey = nil;
            self.doneLoading = false
        }
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey
        //queryExpression.limit = 5
        dynamoDBObjectMapper.scan(SingleMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            
            if self.lastEvaluatedKey == nil {
                self.tableRows?.removeAll(keepingCapacity: true)
            }
            
            if let paginatedOutput = task.result {
                for item in paginatedOutput.items as! [SingleMovie] {
                    if item.TMDB_movie_id == nil || item.Title == nil {
                        continue
                    }
                    self.tableRows?.append(item)
                    let mirrored_object = Mirror(reflecting: item)
                    
                    
                    for (index, attr) in mirrored_object.children.enumerated() {
                        if let property_name = attr.label as String! {
                            print("Attr \(index): \(property_name) = \(attr.value)")
                        }
                    }
                    print("")
                }
                
                self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                if paginatedOutput.lastEvaluatedKey == nil {
                    self.doneLoading = true
                }
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            
            if let error = task.error as? NSError {
                print("Error: \(error)")
            }
            
            return nil
        })
        
    }

}
