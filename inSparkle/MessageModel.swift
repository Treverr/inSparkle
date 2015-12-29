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
        get {return objectForKey("objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var dateTimeMessage : NSDate {
        get {return objectForKey("dateTimeMessage") as! NSDate}
        set { setObject(newValue, forKey: "dateTimeMessage") }
    }
    
    var recipient : Employee {
        get {return objectForKey("recipient") as! Employee}
        set { setObject(newValue, forKey: "recipient") }
    }
    
    var status : String {
        get {return objectForKey("status") as! String}
        set { setObject(newValue, forKey: "status") }
    }
    
    var messageFromName : String {
        get {return objectForKey("messageFromName") as! String}
        set { setObject(newValue, forKey: "messageFromName") }
    }
    
    var messageFromAddress : String {
        get {return objectForKey("messageFromAddress") as! String}
        set { setObject(newValue, forKey: "messageFromAddress") }
    }
    
    var messageFromPhone : String {
        get {return objectForKey("messageFromPhone") as! String}
        set { setObject(newValue, forKey: "messageFromPhone") }
    }
    
    var theMessage : String {
        get {return objectForKey("theMessage") as! String}
        set { setObject(newValue, forKey: "theMessage") }
    }
    
    var signed : PFUser {
        get {return objectForKey("signed") as! PFUser}
        set { setObject(newValue, forKey: "signed") }
    }
    
}