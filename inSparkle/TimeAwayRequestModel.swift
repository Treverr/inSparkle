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
    
    var requestDate : Date! {
        get { return object(forKey: "requestDate") as! Date }
        set { setObject(newValue!, forKey: "requestDate") }
    }
    
    var type : String! {
        get { return object(forKey: "type") as! String }
        set { setObject(newValue!, forKey: "type") }
    }
    
    var hours : Double! {
        get { return object(forKey: "hours") as! Double }
        set { setObject(newValue!, forKey: "hours") }
    }
    
    var formID : String! {
        get { return object(forKey: "objectId") as! String }
        set { setObject(newValue!, forKey: "objectId") }
    }
    
    var status : String! {
        get { return object(forKey: "status") as! String }
        set { setObject(newValue!, forKey: "status") }
    }
    
    var datesRequested : NSArray! {
        get { return object(forKey: "datesRequested") as! NSArray }
        set { setObject(newValue!, forKey: "datesRequested") }
    }
    
    var employee : Employee {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timeCardDictionary : NSDictionary {
        get { return object(forKey: "datesDict") as! NSDictionary }
        set { setObject(newValue, forKey: "datesDict") }
    }
    
}
