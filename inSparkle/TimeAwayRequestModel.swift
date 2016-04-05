//
//  TimeAwayRequestModel.swift
//  inSparkle
//
//  Created by Trever on 4/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class TimeAwayRequest : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
       return "TimeAwayRequests"
    }
    
    var requestDate : NSDate! {
        get { return objectForKey("requestDate") as! NSDate }
        set { setObject(newValue!, forKey: "requestDate") }
    }
    
    var type : String! {
        get { return objectForKey("type") as! String }
        set { setObject(newValue!, forKey: "type") }
    }
    
    var hours : Double! {
        get { return objectForKey("hours") as! Double }
        set { setObject(newValue!, forKey: "hours") }
    }
    
    var formID : String! {
        get { return objectForKey("objectId") as! String }
        set { setObject(newValue!, forKey: "objectId") }
    }
    
    var status : String! {
        get { return objectForKey("status") as! String }
        set { setObject(newValue!, forKey: "status") }
    }
    
    var datesRequested : NSArray! {
        get { return objectForKey("datesRequested") as! NSArray }
        set { setObject(newValue!, forKey: "datesRequested") }
    }
    
    var employee : Employee {
        get { return objectForKey("employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timeCardDictionary : NSDictionary {
        get { return objectForKey("datesDict") as! NSDictionary }
        set { setObject(newValue, forKey: "datesDict") }
    }
    
}