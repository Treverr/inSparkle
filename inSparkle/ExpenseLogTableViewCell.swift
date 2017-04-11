//
//  ExpenseLogTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 3/21/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class ExpenseLogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var logReasonLabel: UILabel!
    @IBOutlet weak var employeeAndDateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
