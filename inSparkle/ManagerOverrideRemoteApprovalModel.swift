//
//  ManagerOverrideRemoteApprovalModel.swift
//  inSparkle
//
//  Created by Trever on 4/14/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class RemoteApproveRequest : PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "ManagerOverrideRemote"
    }
    
    var requestReason : String! {
        get { return object(forKey: "requestReason") as! String }
        set { setObject(newValue, forKey: "requestReason") }
    }
    
    var requestedBy : Employee {
        get { return object(forKey: "requestedBy") as! Employee }
        set { setObject(newValue, forKey: "requestedBy") }
    }
    
    var respondedBy : Employee? {
        get { return object(forKey: "respondedBy") as? Employee }
        set { setObject(newValue!, forKey: "respondedBy") }
    }
    
    var response : String? {
        get { return object(forKey: "response") as? String }
        set { setObject(newValue!, forKey: "response") }
    }
    
    var overrideType : String? {
        get { return object(forKey: "overrideType") as? String }
        set { setObject(newValue!, forKey: "overrideType") }
    }
    
}
