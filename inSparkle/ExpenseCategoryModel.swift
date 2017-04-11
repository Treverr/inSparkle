//
//  ExpenseCategoryModel.swift
//  inSparkle
//
//  Created by Trever on 3/9/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ExpenseCategory: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpenseCategory"
    }
    
    var name : String {
        get { return object(forKey: "name") as! String  }
        set { setObject(newValue, forKey: "name")      }
    }
    
}
