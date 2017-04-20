//
//  ChatViewController.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 2/21/17.
//
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatRoomModel().deleteRoom(roomId: "test")
        view.backgroundColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        
    }
    
    //
    /*
    @IBAction func sendMessage(_ sender: AnyObject) {
        
        if self.sendTextField.text?.isEmpty == true {
            return
        }
        
        
        let conversation = self.createConversation()
        
        // a field in conversation view controller
        self.conversationDataSource.append(conversation)
        
        // any function that update the ui
        self.updateUIAfterMessageSent()
        
        //line 43
        self.sendMessageToServer(conversation)
        
    }

    
    func sendMessageToServer(_ conversation:Conversation) {
     
        // any function that send conversation to db
        chatServices.sendMessage(conversation).continue { (task) -> AnyObject? in
            
            if let _result = task.result {
                
*****************| push conversation |************************************
                //line 66
                self.sendPush(conversation)
                print(_result)
            }
            
            return nil
            
        }
        
        
        
        
    }
    
    
    func sendPush(_ conversation:Conversation) {
        
        //"us-east-1:bdad4021-75b8-44c1-a079-3b6e9e565b47"
        let poolID = Bundle.getPoolId()
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:regionType(Bundle.getRegionFromCreadentialProvider()),
                                                                identityPoolId:poolID)
        
        let configuration = AWSServiceConfiguration(region:regionType(Bundle.getRegionFromPushManager()), credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //start pushing the message
        for userProfile in recipientUsers {
            
            //skip to current user
            if userProfile._userId == AWSIdentityManager.defaultIdentityManager().identityId {
                
                continue
            }
            
            if let targetArns = userProfile._pushTargetArn {
                
                
                for deviceTargetArn in targetArns {
                    
                    do {
     *****************************************************************************************
                        //send json here
     
                        let sns = AWSSNS.default()
                        let request = AWSSNSPublishInput()
                        request.messageStructure = "json"
                        
                        
                        let senderName = AWSIdentityManager.defaultIdentityManager().userName
                        
                        //let defaultMessageFormat = "Message sent by \(senderName!)"
                        //let dataFormat = "\"chatRoomId\":\"\(conversation._chatRoomId!)\""
                        
                        let devicePayLoad = ["default": "Message sent by \(senderName!)", "APNS_SANDBOX": "{\"aps\":{\"alert\": \"Message sent by \(senderName!)\",\"sound\":\"default\", \"badge\":\"1\"}, \"chatRoomId\":\"\(conversation._chatRoomId!)\" }","APNS": "{\"aps\":{\"alert\": \"Message sent by \(senderName!)\"}, \"chatRoomId\":\"\(conversation._chatRoomId!)\" }","GCM":"{\"data\":{\"message\":\"Message sent by \(senderName!)\", \"chatRoomId\":\"\(conversation._chatRoomId!)\"}}"]
                        
                        
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: devicePayLoad, options: JSONSerialization.WritingOptions.init(rawValue: 0))
     
                        
                        request.subject = "Message Sent By \(senderName)"
                        request.message = NSString(data: jsonData, encoding: String.Encoding.utf8) as? String
                        
                        request.targetArn = deviceTargetArn
                        
                        
                        sns.publish(request).continue { (task) -> AnyObject! in
                            print("error \(task.error), result:; \(task.result)")
                            return nil
                        }
                        
                        
                    } catch let parseError {
                        print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                    }
                    
                }
                
            }
            
            
        }
        
        
    }
    
//app delegate start
     
     
     /**
     * Handles a received push notification.
     * - parameter userInfo: push notification contents
     */
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
         /**
         Intercepts the `- application:didReceiveRemoteNotification:` application delegate.
         
         @param application The app object that received the remote notification.
         @param userInfo    A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`.
         */
        AWSPushManager.defaultPushManager().interceptApplication(application, didReceiveRemoteNotification: userInfo)
     }
     
     
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        AWSMobileClient.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
        
        //userInfo is holds the json
        if let chatRoomId = userInfo["chatRoomId"] as? String {
            
            print(chatRoomId)
            
            
            ChatDynamoDBServices().getChatRoomWithChatRoomId(chatRoomId).continue({ (task) -> AnyObject? in
                
                
                if let chatRoom = task.result as? ChatRoom {
                    
                    print(chatRoom)
     
                    var defaultMessage = ""
                    
                    if let _defaultMessage = userInfo["aps"]!["alert"]! as String! {
                        
                        defaultMessage = _defaultMessage
                        
                    }
                    
                    self.showMessageInConversation(chatRoom,defaultMessage: defaultMessage)
     
                }
                
                return nil
            })
        }
    }
    
    func showMessageInConversation(_ chatRoom:ChatRoom , defaultMessage:String) {
        
        
        guard let _navigationController = self.window?.rootViewController as? UINavigationController else{
            
            showPushAlert(defaultMessage)
            return
        }
        
        
        guard let conversationVC = _navigationController.topViewController as? ConversationViewController where conversationVC.selectedChatRoom!._chatRoomId == chatRoom._chatRoomId else{
            
            showPushAlert(defaultMessage)
            return
        }
        
        
        conversationVC.selectedChatRoom = chatRoom
        
        conversationVC.loadRecipientsAndConversations(false)
        
        print(conversationVC)
        
        
    }
    
    func showPushAlert(_ defaultMessage:String) {
        
        DispatchQueue.main.async(execute: {
            
            let alertController = UIAlertController(title: "Message", message: defaultMessage, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(doneAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        })
    }
//app delegate end
*/
}
