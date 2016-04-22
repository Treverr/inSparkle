//
//  ReActivePOCTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 4/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class ReActivePOCTableViewCell: UITableViewCell {

    @IBOutlet var customerName: UILabel?
    @IBOutlet var weekStartEnd: UILabel?
    @IBOutlet var cancelReasonTextView: UITextView?
    
    func configureCell(customer : String, weekStart : NSDate, weekEnd : NSDate, cancelReason : String?) {
        cancelReasonTextView!.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let weekString = formatter.stringFromDate(weekStart) + " - " + formatter.stringFromDate(weekEnd)
        
        self.customerName!.text! = customer
        self.weekStartEnd!.text! = weekString
        if cancelReason != nil {
            self.cancelReasonTextView!.text! = cancelReason!
        } else {
            self.cancelReasonTextView!.text = "Uknown"
        }
        
    }

}
