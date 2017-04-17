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
    
    func setupData() {
        
//        let jack = Contact()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            let jack = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            
            jack.name = "Jack"
            jack.profileImageName = "profile1"
            
            let msg = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            msg.contact = jack
            msg.text = "Message content testing here this is wayyyyyyyyyyyyy tooooo loong"
            msg.date = Date() as NSDate
            
            let ryan = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            ryan.name = "Ryan"
            ryan.profileImageName = "profile0"
            
            let msg_ryan = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            msg_ryan.contact = ryan
            msg_ryan.text = "Hi there this is awesome"
            msg_ryan.date = Date() as NSDate
            
            
            messages = [msg, msg_ryan]
        }
        
    }
    
}
