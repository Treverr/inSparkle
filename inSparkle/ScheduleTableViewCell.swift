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
    @IBOutlet var confirmed: UIImageView!
    
    public func scheduleCell(customerName : String, weekStart: NSDate, weekEnd : NSDate, isConfirmed : Bool) {
        
        customerNameLabel.text = customerName
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        var weekStartString : String! = nil
        var weekEndString : String! = nil
        
        if weekStart == weekEnd {
            weekStartString = formatter.stringFromDate(weekStart)
            weekScheduleLabel.text = weekStartString
        } else {
            weekStartString = formatter.stringFromDate(weekStart)
            weekEndString = formatter.stringFromDate(weekEnd)
            weekScheduleLabel.text = weekStartString + " - " + weekEndString
        }
 
        if isConfirmed == false {
            confirmed.hidden = true
        } else {
            confirmed.hidden = false
        }
        
    }

}
