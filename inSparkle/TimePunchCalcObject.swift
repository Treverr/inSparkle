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
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return "TimePunchTimeCalculations"
    }
    
    var employee : Employee {
        get { return objectForKey("employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var timePunchedIn : NSDate {
        get { return objectForKey("timePunchedIn") as! NSDate }
        set { setObject(newValue, forKey: "timePunchedIn") }
    }
    
    var timePunchedInObject : TimeClockPunchObj {
        get { return objectForKey("timePunchedInObject") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "timePunchedInObject") }
    }
    
    var timePunchedOut : NSDate {
        get { return objectForKey("timePunchedOut") as! NSDate }
        set { setObject(newValue, forKey: "timePunchedOut") }
    }
    
    var timePunchedOutObject : TimeClockPunchObj {
        get { return objectForKey("timePunchedOutObject") as! TimeClockPunchObj }
        set { setObject(newValue, forKey: "timePunchedOutObject") }
    }
    
    var lunch : Bool {
        get { return objectForKey("lunch") as! Bool }
        set { setObject(newValue, forKey: "lunch") }
    }
    
    var totalTime : Double {
        get { return objectForKey("totalTime") as! Double }
        set { setObject(newValue, forKey: "totalTime") }
    }
}