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
        get { return object(forKey: "sessionToken") as? String }
        set { setObject(newValue!, forKey: "sessionToken") }
    }
    
    var expires : Date? {
        get { return object(forKey: "expiresAt") as? Date }
        set { setObject(newValue!, forKey: "expiresAt") }
    }
    
    var user : PFUser? {
        get { return object(forKey: "user") as? PFUser }
        set { setObject(newValue!, forKey: "user") }
    }
    
    var createdWith : NSObject? {
        get { return object(forKey: "user") as? NSObject }
        set { setObject(newValue!, forKey: "user") }
    }
    
    var installID : String? {
        get { return object(forKey: "installationId") as? String }
        set { setObject(newValue!, forKey: "installationId") }
    }
    
    var restricted : Bool {
        get { return object(forKey: "restricted") as! Bool }
        set { setObject(false, forKey: "restricted") }
    }
}
