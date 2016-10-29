//
//  TimePunchCalcObject.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class TimePunchCalcObject: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "TimePunchTimeCalculations"
    }
    
    var employee : Employee {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timePunchedIn : Date {
        get { return object(forKey: "timePunchedIn") as! Date }
        set { setObject(newValue, forKey: "timePunchedIn") }
    }
    
    var timePunchedInObject : TimeClockPunchObj {
        get { return object(forKey: "timePunchedInObject") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "timePunchedInObject") }
    }
    
    var timePunchedOut : Date {
        get { return object(forKey: "timePunchedOut") as! Date }
        set { setObject(newValue, forKey: "timePunchedOut") }
    }
    
    var timePunchedOutObject : TimeClockPunchObj {
        get { return object(forKey: "timePunchedOutObject") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "timePunchedOutObject") }
    }
    
    var lunch : Bool {
        get { return object(forKey: "lunch") as! Bool }
        set { setObject(newValue, forKey: "lunch") }
    }
    
    var totalTime : Double {
        get { return object(forKey: "totalTime") as! Double }
        set { setObject(newValue, forKey: "totalTime") }
    }
}
