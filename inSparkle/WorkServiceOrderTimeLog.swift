//
//  WorkServiceOrderTimeLog.swift
//  MobileTech
//
//  Created by Trever on 9/6/16.
//  Copyright © 2016 Sparkle Pools, Inc. All rights reserved.
//

import Foundation
import Parse

class WorkServiceOrderTimeLog : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "WorkServiceOrderTimeLog"
    }
    
    var relatedWorkOrderObjectID : String! {
        get {return objectForKey("relatedWorkOrderObjectID") as! String}
        set { setObject(newValue, forKey: "relatedWorkOrderObjectID") }
    }
    
    var userLoggedIn : PFUser {
        get {return objectForKey("userLoggedIn") as! PFUser}
        set { setObject(newValue, forKey: "userLoggedIn") }
    }
    
    var device : String {
        get {return objectForKey("device") as! String}
        set { setObject(newValue, forKey: "device") }
    }
    
    var enter : Bool {
        get {return objectForKey("enter") as! Bool}
        set { setObject(newValue, forKey: "enter") }
    }
    
    var timeStamp : NSDate {
        get {return objectForKey("timeStamp") as! NSDate}
        set { setObject(newValue, forKey: "timeStamp") }
    }


}
