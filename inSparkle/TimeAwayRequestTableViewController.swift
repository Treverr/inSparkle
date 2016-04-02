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
        
        self.selectedDate.frame.size.height = CGFloat(SelectedDatesTimeAway.selectedDates.count * 44)
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        self.selectedDate.frame.size.height = CGFloat(SelectedDatesTimeAway.selectedDates.count * 44)
        print(CGFloat(SelectedDatesTimeAway.selectedDates.count * 44))
    }
    
    func updateSize() {
        self.selectedDate.frame.size.height = CGFloat(SelectedDatesTimeAway.selectedDates.count * 44)
        self.tableView.contentSize.height = CGFloat(self.tableView.contentSize.height + (CGFloat(SelectedDatesTimeAway.selectedDates.count) * 44))
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        let theDate = date.date
        SelectedDatesTimeAway.selectedDates.append(theDate)
        print(SelectedDatesTimeAway.selectedDates.count)
        SelectedDatesTableViewController().reloadTable()
        self.updateSize()
    }
    
    func calendarDidPageToDate(date: Moment) {
        print(date)
    }
    
}