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
    
    var vacationDate : Date! {
        get { return object(forKey: "vacationDate") as! Date }
        set { setObject(newValue, forKey: "vacationDate") }
    }
    
    var vacationHours : Double! {
        get { return object(forKey: "vacationHours") as! Double }
        set { setObject(newValue, forKey: "vacationHours") }
    }
    
    var employee : Employee! {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee") }
    }
    
    var relationTimeAwayRequest : TimeAwayRequest! {
        get { return object(forKey: "relationTimeAwayRequest") as! TimeAwayRequest }
        set { setObject(newValue, forKey: "relationTimeAwayRequest") }
    }
    
}
