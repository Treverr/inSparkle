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
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timePunched : Date {
        get { return object(forKey: "timePunched") as! Date }
        set { setObject(newValue, forKey: "timePunched") }
    }
    
    var punchOutIn : String {
        get { return object(forKey: "punchOutIn") as! String }
        set { setObject(newValue, forKey: "punchOutIn") }
    }
    
    var relatedPunch : TimeClockPunchObj {
        get { return object(forKey: "relatedPunch") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "relatedPunch") }
    }
    
    var relatedTimeCalc : TimePunchCalcObject? {
        get { return object(forKey: "relatedTimeCalc") as? TimePunchCalcObject }
        set { setObject(newValue!, forKey: "relatedTimeCalc") }
    }
    
}
