//
//  CustomerData.swift
//  inSparkle
//
//  Created by Trever on 12/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class CustomerData : PFObject, PFSubclassing {
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        "CustomerData"
    }
    
    var objectID : String {
        get {return objectForKey("objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var accountNumber : String {
        get {return objectForKey("accountNumber") as! String}
        set { setObject(newValue, forKey: "accountNumber") }
    }
    
    var fullName : String {
        get {return objectForKey("fullName") as! String}
        set { setObject(newValue, forKey: "fullName") }
    }
    
    var firstName : String {
        get {return objectForKey("firstName") as! String}
        set { setObject(newValue, forKey: "firstName") }
    }
    
    var lastName : String {
        get {return objectForKey("lastName") as! String}
        set { setObject(newValue, forKey: "lastName") }
    }
    
    var addressCity : String {
        get {return objectForKey("addressCity") as! String}
        set { setObject(newValue, forKey: "addressCity") }
    }
    
    var addressStreet : String {
        get {return objectForKey("addressStreet") as! String}
        set { setObject(newValue, forKey: "addressStreet") }
    }
    
    var addressState : String {
        get {return objectForKey("addressState") as! String}
        set { setObject(newValue, forKey: "addressState") }
    }
    
    var ZIP : String {
        get {return objectForKey("addressZIP") as! String}
        set { setObject(newValue, forKey: "addressZIP") }
    }
    
    var currentBalance : Int {
        get {return objectForKey("currentBalance") as!  Int }
        set { setObject(newValue, forKey: "currentBalance") }
    }
    
    var phoneNumber : String {
        get {return objectForKey("phoneNumber") as!  String }
        set { setObject(newValue, forKey: "phoneNumber") }
    }
    
    var customerOpened : NSDate {
        get {return objectForKey("customerOpened") as!  NSDate }
        set { setObject(newValue, forKey: "customerOpened") }
    }
    
}