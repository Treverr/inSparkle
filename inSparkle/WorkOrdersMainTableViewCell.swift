//
//  WorkOrdersMainTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

open class WorkOrdersMainTableViewCell: UITableViewCell {
    
    @IBOutlet var customerNameLabel: UILabel!
    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    open func configureCell(_ customerName : String, dateCreated : Date, status : String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: dateCreated)
        
        customerNameLabel.text = customerName
        dateCreatedLabel.text = dateString
        statusLabel.text = status
        
    }
}
