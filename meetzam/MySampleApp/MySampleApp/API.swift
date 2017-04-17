//
//  api.swift
//  MySampleApp
//
//  Created by Junpu Fan on 4/8/17.
//
//

import Foundation

class API {
    
    // ==================================================================================
    // private section start
    // ==================================================================================
    
    private let rootUrl = "https://3cxxybjcgc.execute-api.us-east-1.amazonaws.com/MobileHub_Deployments"
    
    private func devicePOSTUrl(userId: String, deviceARN: String) -> String {
        return rootUrl + "/device?" + "userId=" + userId + "&arn=" + deviceARN
    }
    
    private func matchPOSTUrl(userId: String) -> String {
        return rootUrl + "/match?" + "userId=" + userId
    }
    
    private func timeStampPOSTUrl(chatRoomId: String, timeStamp: String) -> String {
        return rootUrl + "/chatroom/time?" + "chatRoomId=" + chatRoomId + "&timeStamp=" + timeStamp
    }

    private func httpRequest(url: String, method: String) {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = method
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
        })
        dataTask.resume()
    }
    
    // ==================================================================================
    // private section end
    // ==================================================================================

    
    
    
    // ==================================================================================
    // Meetzam-API CLient
    // ==================================================================================
    
    
    
    /* 
        Adds deviceARN to a user in userProfile table identified by userId
        userId: unique identifier of a user
        deviceARN: the user's deviceARN to be added to the database
     */
    func addDeviceARNtoDB(userId: String, deviceARN: String) {
        httpRequest(url: devicePOSTUrl(userId: userId, deviceARN: deviceARN), method: "POST")
    }
    

    
    
    /*
        sends a push notification to a user's device, the user is identified by userId
        userId: unique identifier of a user, which is the receiver of the push notification
     */
    func pushMatchNotification(userId: String) {
        httpRequest(url: matchPOSTUrl(userId: userId), method: "POST")
    }
    
    func updateTimeStamp(chatRoomId: String, timeStamp: String) {
        httpRequest(url: timeStampPOSTUrl(chatRoomId: chatRoomId, timeStamp: timeStamp), method: "POST")
    }
}
