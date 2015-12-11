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
    
    var aquaDoor : Bool {
        get { return objectForKey("aquaDoor") as! Bool }
        set { setObject(newValue, forKey: "aquaDoor") }
    }
    
    var locEssentials : String {
        get { return objectForKey("locEssentials") as! String }
        set { setObject(newValue, forKey: "locEssentials") }
    }
    
    var bringCloseChem : Bool {
        get { return objectForKey("bringCloseChem") as! Bool }
        set { setObject(newValue, forKey: "bringCloseChem") }
    }
    
    var takeTrash : Bool {
        get { return objectForKey("takeTrash") as! Bool }
        set { setObject(newValue, forKey: "takeTrash") }
    }
    
    var notes : String? {
        get { return objectForKey("notes") as? String }
        set { setObject(newValue!, forKey: "notes") }
    }
    
}