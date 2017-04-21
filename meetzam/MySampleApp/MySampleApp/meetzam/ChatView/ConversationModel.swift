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
    
    // Usage: it adds a new conversation to DB
    func addConversation(_userId: String, _chatRoomId: String, _message: String)
    {
        print("===== addConversation =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let newConversation = ConversationModel()
        newConversation?.userId = _userId
        newConversation?.conversationId = UUID().uuidString
        newConversation?.chatRoomId = _chatRoomId
        newConversation?.createdAt = Date().iso8601
        newConversation?.message = _message
        mapper.save(newConversation!)
        print("successfully added conversation to DB")
    }
    
    // Usage: it returns all messages given the userid and chatroomid
    func getMessagesGivenKeys(userId: String, chatRoomId: String) -> [ConversationModel]
    {
        print("===== getMessageGivenKeys =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()
        var conversationArray: Array = [ConversationModel]()
        var dummynum: Int = 0
        queryExpression.filterExpression = "userId = :userId AND chatRoomId = :chatRoomId"
        queryExpression.expressionAttributeValues = [":userId": userId, ":chatRoomId": chatRoomId]
        
        mapper.scan(ConversationModel.self, expression: queryExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let conversations = task.result {
                for item in conversations.items as! [ConversationModel] {
                    conversationArray.append(item)
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
        var waiting: Int = 0
        while (dummynum != 6)
        {
            waiting = 1
        }
        for item in conversationArray
        {
            print("the conversation by given key has # \(String(describing: item.conversationId))")
        }
        return conversationArray
    }
    
    func getHistoryRecords(userId_1: String, _chatRoomId_1: String, userId_2: String, _chatRoomId_2: String) -> [ConversationModel]
    {
        print("===== getHistoryRecords =====")
        let record_1 = getMessagesGivenKeys(userId: userId_1, chatRoomId: _chatRoomId_1)
        let record_2 = getMessagesGivenKeys(userId: userId_2, chatRoomId: _chatRoomId_2)
        var totalConversation: Array = [ConversationModel]()
        for item in record_1
        {
            totalConversation.append(item)
        }
        for item in record_2
        {
            totalConversation.append(item)
        }
        totalConversation = totalConversation.sorted(by: { $0.createdAt?.compare($1.createdAt!) == .orderedAscending })
        for item in totalConversation
        {
            print("Get the history: conversation# \(item.conversationId)")
        }
        return totalConversation
    }
    
}
