//
//  WorkOrdersMainTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

public class WorkOrdersMainTableViewCell: UITableViewCell {
    
    @IBOutlet var customerNameLabel: UILabel!
    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    public func configureCell(customerName : String, dateCreated : NSDate, status : String) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        let dateString = dateFormatter.stringFromDate(dateCreated)
        
        customerNameLabel.text = customerName
        dateCreatedLabel.text = dateString
        statusLabel.text = status
        
    }
    
    
}
