//
//  ExpenseItemModel.swift
//  inSparkle
//
//  Created by Trever on 3/8/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ExpenseItem : PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "ExpenseItems"
    }
    
    var merchantName : Merchant {
        get { return object(forKey: "merchantName") as! Merchant }
        set { setObject(newValue, forKey: "merchantName") }
    }
    
    var expenseDate : Date {
        get { return object(forKey: "expenseDate") as! Date }
        set { setObject(newValue, forKey: "expenseDate") }
    }
    
    var category : ExpenseCategory? {
        get { return object(forKey: "category") as? ExpenseCategory }
        set { setObject(newValue!, forKey: "category") }
    }
    
    var dollarAmount : Double? {
        get { return object(forKey: "dollarAmount") as? Double }
        set { setObject(newValue!, forKey: "dollarAmount") }
    }
    
    var paymentMethod : String {
        get { return object(forKey: "paymentMethod") as! String }
        set { setObject(newValue, forKey: "paymentMethod") }
    }
    
    var reimbursable : Bool {
        get { return object(forKey: "reimbursable") as! Bool }
        set { setObject(newValue, forKey: "reimbursable") }
    }
    
    var reference : String? {
        get { return object(forKey: "reference") as? String }
        set { setObject(newValue!, forKey: "reference") }
    }
    
    var descriptionNote : String? {
        get { return object(forKey: "description") as? String }
        set { setObject(newValue!, forKey: "description") }
    }
    
    var attachedReceipt : PFFile? {
        get { return object(forKey: "attachedReceipt") as? PFFile }
        set { setObject(newValue!, forKey: "attachedReceipt") }
    }
    
    var isFlagged : Bool {
        get { return object(forKey: "isFlagged") as! Bool }
        set { setObject(newValue, forKey: "isFlagged") }
    }
}
