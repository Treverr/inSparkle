//
//  VacationTimePunchesModel.swift
//  inSparkle
//
//  Created by Trever on 4/5/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class VacationTimePunch : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "VacationTimeObjects"
    }
    
    var vacationDate : NSDate! {
        get { return objectForKey("vacationDate") as! NSDate }
        set { setObject(newValue, forKey: "vacationDate") }
    }
    
    var vacationHours : Double! {
        get { return objectForKey("vacationHours") as! Double }
        set { setObject(newValue, forKey: "vacationHours") }
    }
    
    var employee : Employee! {
        get { return objectForKey("employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
}