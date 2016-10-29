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
    
    class func parseClassName() -> String {
        return "Employees"
    }
    
    var pinNumber : String? {
        get {return object(forKey: "pinNumber") as? String}
        set { setObject(newValue!, forKey: "pinNumber") }
    }
    
    var firstName : String {
        get {return object(forKey: "firstName") as! String}
        set { setObject(newValue, forKey: "firstName") }
    }
    
    var lastName : String {
        get {return object(forKey: "lastName") as! String}
        set { setObject(newValue, forKey: "lastName") }
    }
    
    var messages : Bool {
        get {return object(forKey: "messages") as! Bool}
        set { setObject(newValue, forKey: "messages") }
    }
    
    var userPoint : PFUser? {
        get {return object(forKey: "userPointer") as? PFUser}
        set { setObject(newValue!, forKey: "userPointer") }
    }
    
    var roleType : Role? {
        get {return object(forKey: "roleType") as? Role}
        set {setObject(newValue!, forKey: "roleType") }
    }
    
    var active : Bool {
        get { return object(forKey: "active") as! Bool }
        set { setObject(newValue, forKey: "active") }
    }
}
