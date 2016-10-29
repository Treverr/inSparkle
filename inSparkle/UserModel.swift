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
        get { return object(forKey: "objectId") as! String }
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var theUsername : String {
        get { return object(forKey: "username") as! String }
        set { setObject(newValue, forKey: "username") }
    }
    
    var isAdmin : Bool {
        get { return object(forKey: "isAdmin") as! Bool }
        set { setObject(newValue, forKey: "isAdmin") }
    }
    
    var employee : Employee {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var specialAccess : NSArray {
        get { return object(forKey: "specialAccess") as! NSArray }
        set { setObject(newValue, forKey: "specialAccess") }
    }
    
    var empEmail : String {
        get { return object(forKey: "email") as! String }
        set { setObject(newValue, forKey: "email") }
    }
    
}
