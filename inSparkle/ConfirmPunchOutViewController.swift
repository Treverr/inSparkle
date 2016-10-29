//
//  ConfirmPunchOutViewController.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class ConfirmPunchOutViewController: UIViewController {
    
    var timer = Timer()
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var timeOfPunch: UILabel!
    @IBOutlet weak var timeIn: UILabel!
    @IBOutlet weak var timeOut: UILabel!
    @IBOutlet weak var hours: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ConfirmPunchOutViewController.dismissView), userInfo: nil, repeats: false)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        employeeName.text = TimeClock.employeeName
        timeOfPunch.text = formatter.string(from: TimeClock.timeOfPunch as Date)
        
        let fullDate = DateFormatter()
        fullDate.dateStyle = .short
        fullDate.timeStyle = .short
        
        timeIn.text = fullDate.string(from: TimeClock.timeInObject as Date)
        timeOut.text = fullDate.string(from: TimeClock.timeOutObject as Date)
        
        hours.text = TimeClock.totalHours
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
