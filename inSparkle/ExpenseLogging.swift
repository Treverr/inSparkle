//
//  LogTypes.swift
//  inSparkle
//
//  Created by Trever on 4/4/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import UIKit

class LogIcons {
    
    class func getIcon(reason: String) -> UIImage {
        
        let defaultIcon = UIImage(named: "ExpenseLog-Default")
        
        let logReasonIcons = [
            "Added Expense"     :   "ExpenseLog-Created",
            "Updated Amount"    :   "ExpenseLog-DollarAmount",
            "Updated Merchant"  :   "ExpenseLog-Merchant",
            "Unfalgged"         :   "ExpenseLog-Flag",
            "Flagged"           :   "ExpenseLog-Flag",
            "Attached File"     :   "ExpenseLog-Attached",
            "Added Comment"     :   "ExpenseLog-AddedComment"
            ]
        
        if logReasonIcons.contains(where: { $0.0 == reason }) {
            return UIImage(named: logReasonIcons[reason]!)!
        }
        return defaultIcon!
    }
    
}

class LogReasons {
    
    class var CreatedExpense : String {
        return "Added Expense"
    }
    
    class var UpdatedAmount : String {
        return "Updated Amount"
    }
    
    class var UpdatedMerchant : String {
        return "Updated Merchant"
    }
    
    class var Unfalgged : String {
        return "Unfalgged"
    }
    
    class var Flagged : String {
        return "Flagged"
    }
    
    class func AttachedFile(fileName: String) -> String {
        return ("Attached File: " + fileName)
    }
    
    class func AddedComment(comment: String) -> String {
        return ("Added Comment: " + comment)
    }
    
}
