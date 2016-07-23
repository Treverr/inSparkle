//
//  WeekList.swift
//  inSparkle
//
//  Created by Trever on 12/17/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class WeekList: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "ScheduleWeekList"
    }
    
    var apptsRemain : Int {
        get { return objectForKey("apptsRemain") as! Int }
        set { setObject(newValue, forKey: "apptsRemain") }
    }
    
    var isOpenWeek : Bool {
        get { return objectForKey("isOpenWeek") as! Bool }
        set { setObject(newValue, forKey: "isOpenWeek") }
    }
    
    var weekStart : NSDate {
        get { return objectForKey("weekStart") as! NSDate }
        set { setObject(newValue, forKey: "weekStart") }
    }
    
    var weekEnd : NSDate {
        get { return objectForKey("weekEnd") as! NSDate }
        set { setObject(newValue, forKey: "weekEnd") }
    }
    
    var maxAppts : Int {
        get { return objectForKey("maxAppts") as! Int }
        set { setObject(newValue, forKey: "maxAppts") }
    }
    
    var numApptsSch : Int {
        get { return objectForKey("numApptsSch") as! Int }
        set { setObject(newValue, forKey: "numApptsSch") }
    }
    
}