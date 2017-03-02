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
/*
class MovieManager : NSObject {
    class func describeTable() -> AWSTask<AnyObject> {
        let dynamoDB = AWSDynamoDB.default()
        
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput?.tableName = AWSDynamoDBTableName
        return dynamoDB.describeTable(describeTableInput!) as! AWSTask<AnyObject>
    }
    
}*/
class SingleMovie : AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    var _movieId: NSNumber?
    var _movieName: String?
    var _popularity: NSNumber?
    var _releaseDate: String?
    var _imagePath: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "_movieId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_movieName"
    }
    
    var tableRows:Array<SingleMovie>?
    var lock:NSLock?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var  doneLoading = false
    
    
    
    func refreshList(_ startFromBeginning: Bool)  {
        print("hello1")
   //     if (self.lock?.try() != nil) {
            print("hello2")
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 5
            dynamoDBObjectMapper.scan(SingleMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepingCapacity: true)
                }
                
                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [SingleMovie] {
                        self.tableRows?.append(item)
                        let mirrored_object = Mirror(reflecting: item)
                        
                        
                        for (index, attr) in mirrored_object.children.enumerated() {
                            if let property_name = attr.label as String! {
                                print("Attr \(index): \(property_name) = \(attr.value)")
                            }
                        }
                        
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
  //      }
    }

}
