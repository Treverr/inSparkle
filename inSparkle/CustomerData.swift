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
    
    class func parseClassName() -> String {
       return "CustomerData"
    }
    
    var objectID : String {
        get {return object(forKey: "objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var accountNumber : String {
        get {return object(forKey: "accountNumber") as! String}
        set { setObject(newValue, forKey: "accountNumber") }
    }
    
    var fullName : String {
        get {return object(forKey: "fullName") as! String}
        set { setObject(newValue, forKey: "fullName") }
    }
    
    var firstName : String? {
        get {return object(forKey: "firstName") as? String}
        set { setObject(newValue!, forKey: "firstName") }
    }
    
    var lastName : String? {
        get {return object(forKey: "lastName") as? String}
        set { setObject(newValue!, forKey: "lastName") }
    }
    
    var addressCity : String {
        get {return object(forKey: "addressCity") as! String}
        set { setObject(newValue, forKey: "addressCity") }
    }
    
    var addressStreet : String {
        get {return object(forKey: "addressStreet") as! String}
        set { setObject(newValue, forKey: "addressStreet") }
    }
    
    var addressState : String {
        get {return object(forKey: "addressState") as! String}
        set { setObject(newValue, forKey: "addressState") }
    }
    
    var ZIP : String {
        get {return object(forKey: "addressZIP") as! String}
        set { setObject(newValue, forKey: "addressZIP") }
    }
    
    var currentBalance : Double {
        get {return object(forKey: "currentBalance") as!  Double }
        set { setObject(newValue, forKey: "currentBalance") }
    }
    
    var phoneNumber : String {
        get {return object(forKey: "phoneNumber") as!  String }
        set { setObject(newValue, forKey: "phoneNumber") }
    }
    
    var customerOpened : Date {
        get {return object(forKey: "customerOpened") as!  Date }
        set { setObject(newValue, forKey: "customerOpened") }
    }
    
}
