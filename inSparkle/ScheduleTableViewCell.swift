//
//  ScheduleTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 11/30/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

open class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var weekScheduleLabel: UILabel!
    @IBOutlet var confirmed: UIImageView!
    
    open func scheduleCell(_ customerName : String, weekStart: Date, weekEnd : Date, isConfirmed : Bool) {
        
        customerNameLabel.text = customerName
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
        
        var weekStartString : String! = nil
        var weekEndString : String! = nil
        
        if weekStart.equalToDate(dateToCompare: weekEnd as NSDate) {
            weekStartString = formatter.string(from: weekStart)
            weekScheduleLabel.text = weekStartString
        } else {
            weekStartString = formatter.string(from: weekStart)
            weekEndString = formatter.string(from: weekEnd)
            weekScheduleLabel.text = weekStartString + " - " + weekEndString
        }
 
        if isConfirmed == false {
            confirmed.isHidden = true
        } else {
            confirmed.isHidden = false
        }
        
    }

}
