//
//  Special Access Model.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class SpecialAccessObj: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "SpecialAccessList"
    }
    
    var accessName : String {
        get { return object(forKey: "accessName") as! String  }
        set { setObject(newValue, forKey: "accessName")     }
    }
    
    var accessDesc : String {
        get { return object(forKey: "accessDesc") as! String  }
        set { setObject(newValue, forKey: "accessDesc")     }
    }
    
}
