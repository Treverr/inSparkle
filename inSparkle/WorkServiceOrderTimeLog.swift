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
    
    var arrive : NSDate? {
        get {return objectForKey("arrive") as? NSDate}
        set { setObject(newValue!, forKey: "arrive") }
    }
    
    var departed : NSDate? {
        get {return objectForKey("departed") as? NSDate}
        set { setObject(newValue!, forKey: "departed") }
    }
    
    var relatedWorkOrder : WorkOrders! {
        get {return objectForKey("relatedWorkOrder") as! WorkOrders}
        set { setObject(newValue, forKey: "relatedWorkOrder") }
    }
    
    var userLoggedIn : PFUser {
        get {return objectForKey("userLoggedIn") as! PFUser}
        set { setObject(newValue, forKey: "userLoggedIn") }
    }
    
    var device : String {
        get {return objectForKey("device") as! String}
        set { setObject(newValue, forKey: "device") }
    }

}