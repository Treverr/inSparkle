//
//  ConfirmPunchOutViewController.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class ConfirmPunchOutViewController: UIViewController {
    
    var timer = NSTimer()
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var timeOfPunch: UILabel!
    @IBOutlet weak var timeIn: UILabel!
    @IBOutlet weak var timeOut: UILabel!
    @IBOutlet weak var hours: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ConfirmPunchOutViewController.dismissView), userInfo: nil, repeats: false)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        
        employeeName.text = TimeClock.employeeName
        timeOfPunch.text = formatter.stringFromDate(TimeClock.timeOfPunch)
        
        let fullDate = NSDateFormatter()
        fullDate.dateStyle = .ShortStyle
        fullDate.timeStyle = .ShortStyle
        
        timeIn.text = fullDate.stringFromDate(TimeClock.timeInObject)
        timeOut.text = fullDate.stringFromDate(TimeClock.timeOutObject)
        
        hours.text = TimeClock.totalHours
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
