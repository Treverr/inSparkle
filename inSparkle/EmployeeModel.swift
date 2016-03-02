//
//  EmployeeModel.swift
//  inSparkle
//
//  Created by Trever on 12/5/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class Employee: PFObject, PFSubclassing {
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return "Employees"
    }
    
    var objectID : String {
        get {return objectForKey("objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var pinNumber : String? {
        get {return objectForKey("pinNumber") as? String}
        set { setObject(newValue!, forKey: "pinNumber") }
    }
    
    var firstName : String {
        get {return objectForKey("firstName") as! String}
        set { setObject(newValue, forKey: "firstName") }
    }
    
    var lastName : String {
        get {return objectForKey("lastName") as! String}
        set { setObject(newValue, forKey: "lastName") }
    }
    
    var messages : Bool {
        get {return objectForKey("messages") as! Bool}
        set { setObject(newValue, forKey: "messages") }
    }
    
    var userPoint : PFUser? {
        get {return objectForKey("userPointer") as? PFUser}
        set { setObject(newValue!, forKey: "userPointer") }
    }
    
    var roleType : Role? {
        get {return objectForKey("roleType") as? Role}
        set {setObject(newValue!, forKey: "roleType") }
    }
    
    var active : Bool {
        get { return objectForKey("active") as! Bool }
        set { setObject(newValue, forKey: "active") }
    }
}
