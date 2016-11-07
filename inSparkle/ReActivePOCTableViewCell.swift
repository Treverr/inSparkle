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
    
    func configureCell(_ customer : String, weekStart : Date, weekEnd : Date, cancelReason : String?) {
        cancelReasonTextView!.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
        
        let weekString = formatter.string(from: weekStart) + " - " + formatter.string(from: weekEnd)
        
        self.customerName!.text! = customer
        self.weekStartEnd!.text! = weekString
        if cancelReason != nil {
            self.cancelReasonTextView!.text! = cancelReason!
        } else {
            self.cancelReasonTextView!.text = "Uknown"
        }
        
    }

}
