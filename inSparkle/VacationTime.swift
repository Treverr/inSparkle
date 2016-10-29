//
//  VacationTime.swift
//  inSparkle
//
//  Created by Trever on 4/3/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class VacationTime : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "VacationTime"
    }
    
    var employee : Employee {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var issuedHours : Double {
        get { return object(forKey: "issuedHours") as! Double }
        set { setObject(newValue, forKey: "issuedHours") }
    }
    
    var hoursPending : Double {
        get { return object(forKey: "hoursPending") as! Double }
        set { setObject(newValue, forKey: "hoursPending") }
    }
    
    var hoursLeft : Double {
        get { return object(forKey: "hoursLeft") as! Double }
        set { setObject(newValue, forKey: "hoursLeft") }
    }
    
}
