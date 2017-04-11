//
//  ConfirmPunchInViewController.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class ConfirmPunchInViewController: UIViewController {
    
    var timer = Timer()
    
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var timeOfPunch: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ConfirmPunchInViewController.dismissView), userInfo: nil, repeats: false)
        
        employeeName.text! = TimeClock.employeeName
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.timeZone = SparkleTimeZone.timeZone
        
        let theTimeString = timeFormatter.string(from: TimeClock.timeOfPunch as Date)
        
        timeOfPunch.text! = theTimeString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayInData(_ punch : TimeClockPunchObj, employee: Employee) {
        let theEmployeeName = employee.firstName + " " + employee.lastName
        let punchTime = punch.timePunched
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = SparkleTimeZone.timeZone
        let punchString = formatter.string(from: punchTime as Date)
        
        timeOfPunch.text = punchString
        employeeName.text = theEmployeeName
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

}
