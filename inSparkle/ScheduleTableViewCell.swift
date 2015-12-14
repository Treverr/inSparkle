//
//  ScheduleTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 11/30/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

public class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var weekScheduleLabel: UILabel!
    
    public func scheduleCell(customerName : String, weekStart: NSDate, weekEnd : NSDate) {
        
        customerNameLabel.text = customerName
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let weekStartString = formatter.stringFromDate(weekStart)
        let weekEndString = formatter.stringFromDate(weekEnd)
        
        weekScheduleLabel.text = weekStartString + " - " + weekEndString
        
    }

}
