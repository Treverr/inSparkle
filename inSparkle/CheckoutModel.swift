//
//  CheckoutModel.swift
//  inSparkle
//
//  Created by Trever on 2/13/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class CheckoutModel: PFObject, PFSubclassing {
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    static func parseClassName() -> String {
        return "ChemicalCheckOut"
    }
    
    var chemicalsCheckedOut : NSArray {
        get {return objectForKey("chemicalsCheckedOut") as! NSArray}
        set { setObject(newValue, forKey: "chemicalsCheckedOut") }
    }
    
    var timeCheckedOut : NSDate {
        get {return objectForKey("timeCheckedOut") as! NSDate}
        set { setObject(newValue, forKey: "timeCheckedOut") }
    }
    
    var employee : Employee {
        get {return objectForKey("employee") as! Employee}
        set { setObject(newValue, forKey: "employee") }
    }
    
}