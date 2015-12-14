//
//  TimeClockPunchObj.swift
//  inSparkle
//
//  Created by Trever on 12/5/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class TimeClockPunchObj: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "TimeClockPunches"
    }
    
    var employee : Employee {
        get { return objectForKey("employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timePunched : NSDate {
        get { return objectForKey("timePunched") as! NSDate }
        set { setObject(newValue, forKey: "timePunched") }
    }
    
    var punchOutIn : String {
        get { return objectForKey("punchOutIn") as! String }
        set { setObject(newValue, forKey: "punchOutIn") }
    }
    
    var relatedPunch : TimeClockPunchObj {
        get { return objectForKey("relatedPunch") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "relatedPunch") }
    }
    
    var relatedTimeCalc : TimePunchCalcObject? {
        get { return objectForKey("relatedTimeCalc") as? TimePunchCalcObject }
        set { setObject(newValue!, forKey: "relatedTimeCalc") }
    }
    
}