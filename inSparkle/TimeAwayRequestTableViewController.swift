//
//  TimeAwayRequestTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/31/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import CalendarView
import SwiftMoment

class TimeAwayRequestTableViewController: UITableViewController {
    
    @IBOutlet var selectedDate : UIView!

    @IBOutlet var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        self.selectedDate.frame.size.height = 100
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        let vc = SelectedDatesTableViewController()
        let theDate = date.date
        vc.selectedDates.append(theDate)

    }
    
    func calendarDidPageToDate(date: Moment) {
        print(date)
    }
    
}