//
//  SOITableViewCell.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

open class SOITableViewCell: UITableViewCell {

    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet var itemLabel: UILabel!
    
    open func soiCell(_ customerName : String, date : Date?, location : String, item : String) {
        
        customerNameLabel.text = customerName.capitalized
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if date != nil {
            dateLabel?.text = formatter.string(from: date!)
        } else {
            dateLabel?.text = ""
        }
        
        locationLabel.text = location
        itemLabel.text = item
    }
    
}
