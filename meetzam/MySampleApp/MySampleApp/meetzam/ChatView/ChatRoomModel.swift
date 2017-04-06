//
//  ChatRoom.swift
//  MySampleApp
//
//  Created by 成熟 稳重 靠谱 on 4/5/17.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper

let AWSDynamoDBChatroom = "meetzam-mobilehub-1569925313-ChatRoom"//"meetzam-mobilehub-1569925313-Movie"
class ChatRoomModel : AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var userId: String?
    var chatRoomId: String?
    var lastActivated: String?
    var recipientId: String?
    
    class func dynamoDBTableName() -> String {
        return AWSDynamoDBChatroom
    }
    
    class func hashKeyAttribute() -> String {
        return "userId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "chatRoomId"
    }
    
    /*
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
    */
    
    func getChatRoomList() -> Set<ChatRoomModel> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("===== getChatRoomList =====")
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBScanExpression()

        queryExpression.filterExpression = "userId = :userId";
        queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!]
        var roomList = Set<ChatRoomModel>()
        
        dynamoDBObjectMapper.scan(SingleMovie.self, expression: queryExpression).continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
        
            if let paginatedOutput = task.result {
                for item in paginatedOutput.items as! [ChatRoomModel] {
                    
                    roomList.insert(item)
                    print("getting room \(item.chatRoomId ?? "no Room") of user \(item.userId ?? "no ID")")
                }
                
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //self.tableView.reloadData()
            if let error = task.error as NSError? {
                print("Error: \(error)")
                
            }
            
            print("get list of chatroom: SUCCESS")
            return nil
        })
        print(roomList.description)
        print("got \(roomList.count) chatrooms")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        return roomList
    }
   
    func getSingleChatRoom(_chatRoomId: String) -> ChatRoomModel {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("===== getSingleChatRoom =====")
        let mapper = AWSDynamoDBObjectMapper.default()
        var getted_chatroom = ChatRoomModel()
        mapper.load(ChatRoomModel.self, hashKey: AWSIdentityManager.default().identityId!, rangeKey: _chatRoomId) .continueWith(executor: AWSExecutor.immediate(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("get single chatroom Error: \(error)")
                getted_chatroom = nil
            } else if let item = task.result as? ChatRoomModel {
                getted_chatroom = item
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return nil
        })
        print("getting room \(getted_chatroom?.chatRoomId ?? "no Room") of user \(getted_chatroom?.userId ?? "no ID")")
        return getted_chatroom!
        
    }
    
    
}
