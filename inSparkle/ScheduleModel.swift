//
//  ScheduleModel.swift
//  inSparkle
//
//  Created by Trever on 12/3/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ScheduleObject : PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Schedule"
    }
    
    var customerName : String {
        get { return objectForKey("customerName") as! String }
        set { setObject(newValue, forKey: "customerName") }
    }
    
    var customerAddress : String {
        get { return objectForKey("customerAddress") as! String }
        set { setObject(newValue, forKey: "customerAddress") }
    }
    
    var customerPhone : String {
        get { return objectForKey("customerPhone") as! String }
        set { setObject(newValue, forKey: "customerPhone") }
    }
    
    var weekStart : NSDate {
        get { return objectForKey("weekStart") as! NSDate }
        set { setObject(newValue, forKey: "weekStart") }
    }
    
    var weekEnd : NSDate {
        get { return objectForKey("weekEnd") as! NSDate }
        set { setObject(newValue, forKey: "weekEnd") }
    }
    
    var isActive : Bool {
        get { return objectForKey("isActive") as! Bool }
        set { setObject(newValue, forKey: "isActive") }
    }
    
    var cancelReason : String {
        get { return objectForKey("cancelReason") as! String }
        set { setObject(newValue, forKey: "cancelReason") }
    }
    
    var objectID : String {
        get { return objectForKey("objectId") as! String }
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var type : String {
        get { return objectForKey("type") as! String }
        set { setObject(newValue, forKey: "type") }
    }
    
    var coverType : String {
        get { return objectForKey("coverType") as! String }
        set { setObject(newValue, forKey: "coverType") }
    }
    
    var aquaDoor : Bool? {
        get { return objectForKey("aquaDoor") as? Bool }
        set { setObject(newValue!, forKey: "aquaDoor") }
    }
    
    var locEssentials : String {
        get { return objectForKey("locEssentials") as! String }
        set { setObject(newValue, forKey: "locEssentials") }
    }
    
    var bringChem : Bool {
        get { return objectForKey("bringChem") as! Bool }
        set { setObject(newValue, forKey: "bringChem") }
    }
    
    var takeTrash : Bool {
        get { return objectForKey("takeTrash") as! Bool }
        set { setObject(newValue, forKey: "takeTrash") }
    }
    
    var notes : String? {
        get { return objectForKey("notes") as? String }
        set { setObject(newValue!, forKey: "notes") }
    }
    
    var canceledBy : String? {
        get { return objectForKey("canceledBy") as? String }
        set { setObject(newValue!, forKey: "canceledBy") }
    }
    
    var confrimed : Bool? {
        get { return objectForKey("confrimed") as? Bool }
        set { setObject(newValue!, forKey: "confrimed") }
    }
    
    var confrimedBy : String? {
        get { return objectForKey("confrimedBy") as? String }
        set { setObject(newValue!, forKey: "confrimedBy") }
    }
    
    var confirmedDate : NSDate? {
        get { return objectForKey("confirmedDate") as? NSDate }
        set { setObject(newValue!, forKey: "confirmedDate") }
    }
    
}