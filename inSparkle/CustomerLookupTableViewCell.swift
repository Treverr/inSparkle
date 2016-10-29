//
//  CustomerLookupTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 12/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

open class CustomerLookupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var addressStreet: UILabel!
    @IBOutlet weak var addressRest: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    open func customerCell(_ _customerName : String, _addressStreet : String, _addressRest : String, _phoneNumber : String, _balance : Int?, editButton : UIButton) {
        
        customerName.text = _customerName
        addressStreet.text = _addressStreet
        addressRest.text = _addressRest
        phoneNumber.text = _phoneNumber
        if _balance != 0 {
            balance.text = "$\(_balance)"
        }
        
    }

}
