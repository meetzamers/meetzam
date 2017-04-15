//
//  ConversationModel.swift
//  MySampleApp
//
//  Created by Rainy on 2017/4/5.
//
//
import Foundation
import UIKit
import AWSDynamoDB
class ConversationModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var userId: String?
    var conversationId: String?
    var chatRoomId: String?
    var createdAt: String?
    var message: String?
    
    class func dynamoDBTableName() -> String {
        
        return "meetzam-mobilehub-1569925313-Conversation"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "conversationId"
    }
    
    func getMessagesGivenKeys(userId: String, chatRoomId: String) -> [ConversationModel]
    {
        print("===== getMessageGivenKeys =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        var conversationArray: Array = [ConversationModel]()
        var dummynum: Int = 0
        queryExpression.filterExpression = "userId = :userId"
        queryExpression.expressionAttributeValues = [":userId": userId]
        queryExpression.filterExpression = "chatRoomId = :chatRoomId"
        queryExpression.expressionAttributeValues = [":chatRoomId": chatRoomId]
        
        mapper.scan(ConversationModel.self, expression: queryExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let conversations = task.result {
                for item in conversations.items as! [ConversationModel] {
                    conversationArray.append(item)
                    print("getting conversation \(item.conversationId ?? "no such conversation"): \(item.userId ?? "no ID")")
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
            print("get requested conversations: SUCCESS")
            dummynum = 6
            return nil
        })
        while (dummynum != 6)
        {
            print("getMessagesGivenKeys waiting")
        }
        return conversationArray
    }
}
