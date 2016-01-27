//
//  MessagesMainTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 12/23/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

public class MessagesMainTableViewCell: UITableViewCell {
    
    
    @IBOutlet var unreadIndicator: UIImageView!
    @IBOutlet var customerName: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var statusOfMessageLabel: UILabel!
    @IBOutlet var statusTimeLabel: UILabel!
    
    public func configureCell(customerName_ : String, date : NSDate, messageStatus : String, statusTime : NSDate, unread : Bool) {
        
        if !unread {
            unreadIndicator.hidden = true
        }
        
        customerName.text! = customerName_
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        dateLabel.text! = formatter.stringFromDate(date)
        
        if messageStatus == "Unread" {
            statusOfMessageLabel.text! = messageStatus
        } else {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateStyle = .ShortStyle
            timeFormatter.timeStyle = .ShortStyle
            timeFormatter.doesRelativeDateFormatting = true
            
            statusOfMessageLabel.text! = messageStatus + " - " + timeFormatter.stringFromDate(statusTime)
        }
    }
}
