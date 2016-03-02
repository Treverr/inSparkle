//
//  RoleModel.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class Role: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Roles"
    }
    
    var roleName : String! {
        get { return objectForKey("roleName") as! String }
        set { setObject(newValue, forKey: "roleName") }
    }
    
}