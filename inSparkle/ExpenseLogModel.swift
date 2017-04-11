//
//  ExpenseLogModel.swift
//  inSparkle
//
//  Created by Trever on 3/11/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ExpenseLog: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpenseLog"
    }
    
    var expenseObject : ExpenseItem {
        get { return object(forKey: "expenseObject") as! ExpenseItem }
        set { setObject(newValue, forKey: "expenseObject")  }
    }
    
    var employee : Employee {
        get { return object(forKey: "employee") as! Employee }
        set { setObject(newValue, forKey: "employee")  }
    }
    
    var logReason : String {
        get { return object(forKey: "logReason") as! String }
        set { setObject(newValue, forKey: "logReason")  }
    }
    
}
