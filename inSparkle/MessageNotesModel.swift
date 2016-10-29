//
//  MessageNotes.swift
//  inSparkle
//
//  Created by Trever on 1/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class MessageNotes: PFObject, PFSubclassing {
   
    static func parseClassName() -> String {
        return "MessageNotes"
    }
    
    var objectID : String {
        get {return object(forKey: "objectId") as! String}
        set { setObject(newValue, forKey: "objectId") }
    }
    
    var pointerMessage : Messages {
        get {return object(forKey: "pointerMessage") as! Messages}
        set { setObject(newValue, forKey: "pointerMessage") }
    }
    
    var createdBy : Employee? {
        get {return object(forKey: "createdBy") as? Employee}
        set { setObject(newValue!, forKey: "createdBy") }
    }

    var note : String {
        get {return object(forKey: "note") as! String}
        set { setObject(newValue, forKey: "note") }
    }
    
}
