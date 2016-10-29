//
//  EditTimeDatePickerViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class EditTimeDatePickerViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    
    var passedDate = EditTimePunchesDatePicker.dateToPass
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(EditTimeDatePickerViewController.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
        
        datePicker.date = passedDate!

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged(_ datePicker : UIDatePicker) {
        
       EditTimePunchesDatePicker.dateToPass = datePicker.date
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyDateLabelToUpdate"), object: nil)
        
    }

}
