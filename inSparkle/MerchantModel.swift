//
//  MerchantModel.swift
//  inSparkle
//
//  Created by Trever on 3/8/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class Merchant: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpenseMerchants"
    }
    
    var name : String {
        get { return object(forKey: "name") as! String }
        set { setObject(newValue, forKey: "name") }
    }
    
}
