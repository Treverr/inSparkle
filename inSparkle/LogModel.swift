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
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    static func parseClassName() -> String {
        return "Log"
    }
    
    var employee : Employee {
        get {return objectForKey("employee") as! Employee}
        set { setObject(newValue, forKey: "employee") }
    }
    
    var logDescription : String {
        get {return objectForKey("logDescription") as! String}
        set { setObject(newValue, forKey: "logDescription") }
    }
    
}