//
//  MessagesMainTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 12/23/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

open class MessagesMainTableViewCell: UITableViewCell {
    
    
    @IBOutlet var unreadIndicator: UIImageView!
    @IBOutlet var customerName: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var statusOfMessageLabel: UILabel!
    @IBOutlet var statusTimeLabel: UILabel!
    
    open func configureCell(_ customerName_ : String, date : Date, messageStatus : String, statusTime : Date, unread : Bool) {
        
        if unread == false {
            unreadIndicator.isHidden = true
        } else {
            unreadIndicator.isHidden = false
        }
        
        customerName.text! = customerName_
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text! = formatter.string(from: date)
        
        if messageStatus == "Unread" {
            statusOfMessageLabel.text! = messageStatus
        } else {
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .short
            timeFormatter.timeStyle = .short
            timeFormatter.doesRelativeDateFormatting = true
            
            statusOfMessageLabel.text! = messageStatus + " - " + timeFormatter.string(from: statusTime)
        }
    }
}
