//
//  ChemicalCheckoutTableViewCell.swift
//  
//
//  Created by Trever on 2/15/16.
//
//

import UIKit
import Parse

public class ChemicalCheckoutPDFTemplateTableViewCell: UITableViewCell {

    @IBOutlet var employeeName: UILabel!
    @IBOutlet var chemicalName: UILabel!
    @IBOutlet var qtyLabel: UILabel!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureCell(employee : PFObject, chemical : String, QTY : String) {
        let emp = employee as! Employee
        let empName = emp.firstName.capitalizedString + " " + emp.lastName.capitalizedString
        
        employeeName.text! = empName
        chemicalName.text! = chemical
        qtyLabel.text! = QTY
    }

}
