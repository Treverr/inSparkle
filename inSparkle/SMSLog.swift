//
//  SMSLog.swift
//  inSparkle
//
//  Created by Trever on 2/13/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class SMSLog : PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "SMSLog"
    }
    
    var smsSentTo : String {
        get { return object(forKey: "smsSentTo") as! String }
        set { setObject(newValue, forKey: "smsSentTo") }
    }
    
    var messageContent : String {
        get { return object(forKey: "messageContent") as! String }
        set { setObject(newValue, forKey: "messageContent") }
    }
    
}
