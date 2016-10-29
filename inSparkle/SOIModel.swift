//
//  SOIModel.swift
//  inSparkle
//
//  Created by Trever on 11/18/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class SOIObject: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "SOI"
    }
    
    var customerName : String {
        get { return object(forKey: "customerName") as! String }
        set { setObject(newValue.capitalized, forKey: "customerName") }
    }
    
    var date : Date? {
        get { return object(forKey: "date") as? Date }
        set { setObject(newValue!, forKey: "date") }
    }
    
    var location : String {
        get { return object(forKey: "location") as! String }
        set { setObject(newValue, forKey: "location") }
    }
    
    var category : String {
        get { return object(forKey: "category") as! String }
        set { setObject(newValue, forKey: "location") }
    }
    
    var serial : String? {
        get { return object(forKey: "serial") as? String }
        set { setObject(newValue!, forKey: "serial") }
    }
    
    var isActive : Bool {
        get { return object(forKey: "isActive") as! Bool }
        set { setObject(newValue, forKey: "isActive") }
    }
    
    var objectID : String {
        get { return object(forKey: "objectId") as! String }
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var orderNumber : String? {
        get { return object(forKey: "orderNumber") as? String }
        set { setObject(newValue!, forKey: "orderNumber") }
    }
    
}
