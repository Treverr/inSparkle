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
        get { return object(forKey: "apptsRemain") as! Int }
        set { setObject(newValue, forKey: "apptsRemain") }
    }
    
    var isOpenWeek : Bool {
        get { return object(forKey: "isOpenWeek") as! Bool }
        set { setObject(newValue, forKey: "isOpenWeek") }
    }
    
    var weekStart : Date {
        get { return object(forKey: "weekStart") as! Date }
        set { setObject(newValue, forKey: "weekStart") }
    }
    
    var weekEnd : Date {
        get { return object(forKey: "weekEnd") as! Date }
        set { setObject(newValue, forKey: "weekEnd") }
    }
    
    var maxAppts : Int {
        get { return object(forKey: "maxAppts") as! Int }
        set { setObject(newValue, forKey: "maxAppts") }
    }
    
    var numApptsSch : Int {
        get { return object(forKey: "numApptsSch") as! Int }
        set { setObject(newValue, forKey: "numApptsSch") }
    }
    
}
