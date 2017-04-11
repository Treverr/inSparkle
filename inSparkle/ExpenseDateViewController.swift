//
//  ExpenseDateViewController.swift
//  inSparkle
//
//  Created by Trever on 3/9/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class ExpenseDateViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setupNavigationbar(self.navigationController!)
        self.datePicker.date = Date()
        self.datePicker.maximumDate = Date()
    }

    @IBAction func doneButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateExpenseDate"), object: self.datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
}
