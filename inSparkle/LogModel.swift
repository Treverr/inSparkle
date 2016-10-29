//
//  LogModel.swift
//  inSparkle
//
//  Created by Trever on 4/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class Logs: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Log"
    }
    
    var employee : Employee {
        get {return object(forKey: "employee") as! Employee}
        set { setObject(newValue, forKey: "employee") }
    }
    
    var logDescription : String {
        get {return object(forKey: "logDescription") as! String}
        set { setObject(newValue, forKey: "logDescription") }
    }
    
}
