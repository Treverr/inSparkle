//
//  UserModel.swift
//  inSparkle
//
//  Created by Trever on 12/27/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class inSparkleUsers : PFUser {
    
    var objectID : String {
        get { return objectForKey("objectId") as! String }
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var theUsername : String {
        get { return objectForKey("username") as! String }
        set { setObject(newValue, forKey: "username") }
    }
    
    var isAdmin : Bool {
        get { return objectForKey("isAdmin") as! Bool }
        set { setObject(newValue, forKey: "isAdmin") }
    }
    
    var employee : Employee {
        get { return objectForKey("employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var specialAccess : NSArray {
        get { return objectForKey("specialAccess") as! NSArray }
        set { setObject(newValue, forKey: "specialAccess") }
    }
    
    var empEmail : String {
        get { return objectForKey("email") as! String }
        set { setObject(newValue, forKey: "email") }
    }
    
}