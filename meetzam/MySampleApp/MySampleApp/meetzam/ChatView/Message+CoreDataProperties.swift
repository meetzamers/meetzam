//
//  Message+CoreDataProperties.swift
//  MySampleApp
//
//  Created by ZuYuan Fan on 4/17/17.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var contact: Contact?

}
