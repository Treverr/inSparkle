//
//  ConfirmPunchInViewController.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class ConfirmPunchInViewController: UIViewController {
    
    var timer = NSTimer()
    
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var timeOfPunch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "dismissView", userInfo: nil, repeats: false)
        
        employeeName.text! = TimeClock.employeeName
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle
        
        let theTimeString = timeFormatter.stringFromDate(TimeClock.timeOfPunch)
        
        timeOfPunch.text! = theTimeString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayInData(punch : TimeClockPunchObj, employee: Employee) {
        let theEmployeeName = employee.firstName + " " + employee.lastName
        let punchTime = punch.timePunched
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        let punchString = formatter.stringFromDate(punchTime)
        
        timeOfPunch.text = punchString
        employeeName.text = theEmployeeName
    }
    
    func dismissView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
