//
//  CalendarDatePickerViewController.swift
//  inSparkle
//
//  Created by Trever on 12/8/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import CalendarView
import SwiftMoment

class CalendarDatePickerViewController: UIViewController {

    @IBOutlet var calendar: CalendarView!
    
    var date : Moment! {
        didSet {
            title = date.format("MMMM d, yyyy")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        date = moment()
        calendar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarDatePickerViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        self.date = date
        if TimeClockReportAllEmployee.startEnd == "start" {
            TimeClockReportAllEmployee.selectedStartDate = date.format("MMMM d, yyyy")
            self.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("updateStart", object: nil)
        }
        if TimeClockReportAllEmployee.startEnd == "end" {
            TimeClockReportAllEmployee.selectedEndDate = date.format("MMMM d, yyyy")
            self.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("updateEnd", object: nil)
        }
    }
    
    func calendarDidPageToDate(date: Moment) {
        self.date = date
        
        title = date.format("MMMM yyyy")
    }
    
}