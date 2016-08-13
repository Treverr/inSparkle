//
//  SessionModel.swift
//  inSparkle
//
//  Created by Trever on 8/12/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class SessionModel : PFSession {
    
    var token: String? {
        get { return objectForKey("sessionToken") as? String }
        set { setObject(newValue!, forKey: "sessionToken") }
    }
    
    var expires : NSDate? {
        get { return objectForKey("expiresAt") as? NSDate }
        set { setObject(newValue!, forKey: "expiresAt") }
    }
    
    var user : PFUser? {
        get { return objectForKey("user") as? PFUser }
        set { setObject(newValue!, forKey: "user") }
    }
    
    var createdWith : NSObject? {
        get { return objectForKey("user") as? NSObject }
        set { setObject(newValue!, forKey: "user") }
    }
    
    var installID : String? {
        get { return objectForKey("installationId") as? String }
        set { setObject(newValue!, forKey: "installationId") }
    }
    
    var restricted : Bool {
        get { return objectForKey("restricted") as! Bool }
        set { setObject(false, forKey: "restricted") }
    }
}