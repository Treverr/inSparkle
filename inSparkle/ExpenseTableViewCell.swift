//
//  ExpenseTableViewCell.swift
//  Pods
//
//  Created by Trever on 3/1/17.
//
//

import UIKit
import MGSwipeTableCell

class ExpenseTableViewCell: MGSwipeTableCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = UIColor.white
            self.contentView.backgroundColor = Colors.sparkleBlue.withAlphaComponent(0.25)
        } else {
            self.backgroundColor = UIColor.white
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var expenseDate: UILabel!
    @IBOutlet weak var expenseCost: UILabel!
    @IBOutlet weak var attachmentImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
    

}
