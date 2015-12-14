//
//  SOIModel.swift
//  inSparkle
//
//  Created by Trever on 11/18/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class SOIObject: PFObject {
    
    class func parseClassName() -> String! {
        return "SOI"
    }
    
    var customerName : String {
        get { return objectForKey("customerName") as! String }
        set { setObject(newValue, forKey: "customerName") }
    }
    
    var date : NSDate? {
        get { return objectForKey("date") as? NSDate }
        set { setObject(newValue!, forKey: "date") }
    }
    
    var location : String {
        get { return objectForKey("location") as! String }
        set { setObject(newValue, forKey: "location") }
    }
    
    var category : String {
        get { return objectForKey("category") as! String }
        set { setObject(newValue, forKey: "location") }
    }
    
    var serial : String? {
        get { return objectForKey("serial") as? String }
        set { setObject(newValue!, forKey: "serial") }
    }
    
    var isActive : Bool {
        get { return objectForKey("isActive") as! Bool }
        set { setObject(newValue, forKey: "isActive") }
    }
    
    var objectID : String {
        get { return objectForKey("objectId") as! String }
        set { setObject(newValue, forKey: "objectId") }
    }
    
}