//
//  PaymentTypeModel.swift
//  inSparkle
//
//  Created by Trever on 3/8/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class PaymentType : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpensePaymentTypes"
    }
    
    var name : String {
        get { return object(forKey: "name") as! String  }
        set { setObject(newValue, forKey: "name")       }
    }
    
    var type : String {
        get { return object(forKey: "name") as! String  }
        set { setObject(newValue, forKey: "name")       }
    }
    
    
}
