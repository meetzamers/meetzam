//
//  ChatContactControllerHelper.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 4/17/17.
//
//

import UIKit
import CoreData

extension ChatViewController {
    
    // clean data in core data
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
           
            do {
                let entityNames = ["Contact", "Message"]
                
                for entityname in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityname)
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    
                    for obj in objects! {
                        context.delete(obj)
                    }
                }
                try(context.save())
                
            } catch let err {
                print(err)
            }
        }
    }
    
    // setup data to core data
    func setupData() {
        // MUST clear core data first, or there will be duplicated messages in core data
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            // create contacts and messages
            var chatRoomList = ChatRoomModel().getChatRoomList()
            print(chatRoomList.count)
            if chatRoomList.count != 0 {
                chatRoomList = ChatRoomModel().sortByTime(roomList: chatRoomList) // Sorted List
                for singleChatRoom in chatRoomList {
                    // DB
                    let contactID = singleChatRoom.recipientId!
                    var contactIDs = [String]()
                    contactIDs.append(contactID)
                    let contactName = UserProfileToDB().getUserProfileByIds(userIDs: contactIDs)[0].displayName
                    let imagePath_string = UserProfileToDB().downloadUserIcon(userID: contactID).path
                    let chatRoomID_2 = ChatRoomModel().getChatRoomId(userId: contactID, recipientId: singleChatRoom.userId!)
                    
                    // Local
                    let localContact = self.createContactwithName(name: contactName!, profileimageName: imagePath_string, context: context, userID: contactID)
                    let allMessages = ConversationModel().getHistoryRecords(userId_1: singleChatRoom.userId!, _chatRoomId_1: singleChatRoom.chatRoomId!, userId_2: contactID, _chatRoomId_2: chatRoomID_2)
                    
                    for singleMessage in allMessages {
                        let localText = singleMessage.message
                        let createDate = singleMessage.createdAt?.dateFromISO8601
                        
                        if singleMessage.userId != contactID {
                            ChatViewController.createMessagewithText(text: localText!, contact: localContact, minutesAgo: createDate!, context: context, issender: true)
                        }
                        else {
                            ChatViewController.createMessagewithText(text: localText!, contact: localContact, minutesAgo: createDate!, context: context)
                        }
                        
                    }
                    
                }
            }
            
            
            // save these data into context(core data)
            do {
                try(context.save())
            } catch let error {
                print(error)
            }
            
        }

    }
    
    func incomingData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            var chatRoomList = ChatRoomModel().getChatRoomList()
            print(chatRoomList.count)
            if chatRoomList.count != 0 {
                chatRoomList = ChatRoomModel().sortByTime(roomList: chatRoomList) // Sorted List
                for singleChatRoom in chatRoomList {
                    // DB
                    let contactID = singleChatRoom.recipientId!
                    let contactName = UserProfileToDB().getUserProfileByIds(userIDs: [contactID])[0].displayName
                    let imagePath_string = UserProfileToDB().downloadUserIcon(userID: contactID).path
                    let chatRoomID_2 = ChatRoomModel().getChatRoomId(userId: contactID, recipientId: singleChatRoom.userId!)
                    
                    // Local
                    let allMessages = ConversationModel().getHistoryRecords(userId_1: singleChatRoom.userId!, _chatRoomId_1: singleChatRoom.chatRoomId!, userId_2: contactID, _chatRoomId_2: chatRoomID_2)
                    
                    // Update contact
                    // TODO TODO TODO test this function
                    let newrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
                    newrequest.predicate = NSPredicate(format: "userID = %@", contactID)
                    newrequest.fetchLimit = 1
                    do {
                        let contact = try context.fetch(newrequest) as! [Contact]
                        if contact.count == 0 {
                            self.createContactwithName(name: contactName!, profileimageName: imagePath_string, context: context, userID: contactID)
                        }
                    } catch let err {
                        print(err)
                    }
                    // TODO TODO TODO test this function
                    
                    
                    // Update new message
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
                    request.predicate = NSPredicate(format: "lastMessage.text == %@", (allMessages.last?.message)!)
                    request.fetchLimit = 1
                    
                    do {
                        let fetchResults = try context.fetch(request)
                        if fetchResults.count > 0 {
                            print("already")
                        }
                        else {
                            let newrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
                            newrequest.predicate = NSPredicate(format: "userID = %@", contactID)
                            newrequest.fetchLimit = 1
                            
                            let contact = try context.fetch(newrequest) as! [Contact]
                            ChatViewController.createMessagewithText(text: (allMessages.last?.message)!, contact: contact.first!, minutesAgo: (allMessages.last?.createdAt?.dateFromISO8601)!, context: context)
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
            
            // save these data into context(core data)
            do {
                try(context.save())
            } catch let error {
                print(error)
            }
            
        }
    }
    
    // helper function to help create multiple contacts
    private func createContactwithName(name: String, profileimageName: String, context: NSManagedObjectContext, userID: String) -> Contact {
        let cont = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
        cont.name = name
        cont.profileImageName = profileimageName
        cont.userID = userID
        
        return cont
    }
    
    // helper function to help create multiple messages
    static func createMessagewithText(text: String, contact: Contact, minutesAgo: Date, context: NSManagedObjectContext, issender: Bool = false) {
        let msg = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        msg.contact = contact
        msg.text = text
        msg.date = minutesAgo as NSDate
        msg.isSender = issender
        
        contact.lastMessage = msg
        
    }
    
}
