//
//  SOITableViewCell.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

public class SOITableViewCell: UITableViewCell {

    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel!
    
    public func soiCell(customerName : String, date : NSDate?, location : String) {
        
        customerNameLabel.text = customerName
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        
        if date != nil {
            dateLabel?.text = formatter.stringFromDate(date!)
        } else {
            dateLabel?.text = ""
        }
        
        locationLabel.text = location
        
    }
    
}
