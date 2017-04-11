//
//  ExpenseAdditionalAttachments.swift
//  inSparkle
//
//  Created by Trever on 3/13/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ExpenseAdditionalAttachments : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpenseAdditionalAttachments"
    }
    
    var expenseItem : ExpenseItem {
        get { return object(forKey: "expenseItem") as! ExpenseItem  }
        set { setObject(newValue, forKey: "expenseItem") }
    }
    
    var attachment : PFFile {
        get { return object(forKey: "attachment") as! PFFile  }
        set { setObject(newValue, forKey: "attachment") }
    }
    
    var attachedByEmployee : Employee {
        get { return object(forKey: "attachedByEmployee") as! Employee  }
        set { setObject(newValue, forKey: "attachedByEmployee") }
    }
    
    var notes : String? {
        get { return object(forKey: "notes") as? String  }
        set { setObject(newValue!, forKey: "notes") }
    }
    
    var fileName : String {
        get { return object(forKey: "fileName") as! String  }
        set { setObject(newValue, forKey: "fileName") }
    }
    
}
