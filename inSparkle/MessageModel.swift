//
//  MessageModel.swift
//  inSparkle
//
//  Created by Trever on 12/28/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class Messages : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
       return "Messages"
    }
    
    var objectID : String {
        get {return object(forKey: "objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var dateTimeMessage : Date {
        get {return object(forKey: "dateTimeMessage") as! Date}
        set { setObject(newValue, forKey: "dateTimeMessage") }
    }
    
    var recipient : Employee {
        get {return object(forKey: "recipient") as! Employee}
        set { setObject(newValue, forKey: "recipient") }
    }
    
    var status : String {
        get {return object(forKey: "status") as! String}
        set { setObject(newValue, forKey: "status") }
    }
    
    var statusTime : Date {
        get {return object(forKey: "statusTime") as! Date}
        set { setObject(newValue, forKey: "statusTime") }
    }
    
    var unread : Bool {
        get {return object(forKey: "unread") as! Bool}
        set { setObject(newValue, forKey: "unread") }
    }
    
    var messageFromName : String {
        get {return object(forKey: "messageFromName") as! String}
        set { setObject(newValue, forKey: "messageFromName") }
    }
    
    var messageFromAddress : String? {
        get {return object(forKey: "messageFromAddress") as? String}
        set { setObject(newValue!, forKey: "messageFromAddress") }
    }
    
    var messageFromPhone : String {
        get {return object(forKey: "messageFromPhone") as! String}
        set { setObject(newValue, forKey: "messageFromPhone") }
    }
    
    var theMessage : String {
        get {return object(forKey: "theMessage") as! String}
        set { setObject(newValue, forKey: "theMessage") }
    }
    
    var dateEntered : Date {
        get {return object(forKey: "dateEntered") as! Date}
        set { setObject(newValue, forKey: "dateEntered") }
    }
    
    var signed : PFUser {
        get {return object(forKey: "signed") as! PFUser}
        set { setObject(newValue, forKey: "signed") }
    }
    
    var isUrgent : Bool {
        get {return object(forKey: "isUrgent") as! Bool}
        set { setObject(newValue, forKey: "isUrgent") }
    }
    
    var altPhone : String? {
        get {return object(forKey: "altPhone") as? String}
        set { setObject(newValue!, forKey: "altPhone") }
    }
    
    var emailAddy : String? {
        get {return object(forKey: "emailAddy") as? String}
        set { setObject(newValue!, forKey: "emailAddy") }
    }
    
}
