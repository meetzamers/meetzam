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
            
            // Jack
            let jack = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            jack.name = "Jack"
            jack.profileImageName = "profile1"
            createMessagewithText(text: "Message content testing here this is wayyyyyyyyyyyyy tooooo loong", contact: jack, minutesAgo: 60 * 24 * 8, context: context)
            
            // Ryan
            let ryan = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            ryan.name = "Ryan"
            ryan.profileImageName = "profile0"
            createMessagewithText(text: "Hi there this is awesome", contact: ryan, minutesAgo: 10, context: context)
            createMessagewithText(text: "I'm trying to finish it", contact: ryan, minutesAgo: 6, context: context)
            createMessagewithText(text: "Hello how are you??", contact: ryan, minutesAgo: 2, context: context)
            
            // Rose
            let rose = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            rose.name = "Rose"
            rose.profileImageName = "profile2"
            createMessagewithText(text: "I love Jack", contact: rose, minutesAgo: 60 * 24, context: context)
            
            
            // save these data into context(core data)
            do {
                try(context.save())
            } catch let error {
                print(error)
            }
            
        }
        
        // load the data
        loadData()
    }
    
    // helper function to help create multiple messages
    private func createMessagewithText(text: String, contact: Contact, minutesAgo: Double, context: NSManagedObjectContext) {
        let msg = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        msg.contact = contact
        msg.text = text
        msg.date = NSDate().addingTimeInterval(-minutesAgo * 60)
    }
    
    // load data from core data
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            if let contacts = fetchContacts() {
                messages = [Message]()
                
                for contact in contacts {
                    print(contact.name as Any)
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "contact.name = %@", contact.name!)
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let fetchedmsgs = try(context.fetch(fetchRequest)) as? [Message]
                        messages?.append(contentsOf: fetchedmsgs!)
                        
                    } catch let err {
                        print(err)
                    }
                    
                }
                
                // sort messages for all contacts in order
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
                
            }
        }
    }
    
    // fetch all contacts
    private func fetchContacts() -> [Contact]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
            
            do {
                return try(context.fetch(request)) as? [Contact]
                
            } catch let err {
                print(err)
            }
            
        }
        
        return nil
    }
    
}
