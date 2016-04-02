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
    
    var originalHeight : CGFloat!
    
    @IBOutlet var selectedDate : UIView!

    @IBOutlet var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalHeight = self.tableView.contentSize.height
        
        calendarView.delegate = self
        
        self.selectedDate.frame.size.height = CGFloat(SelectedDatesTimeAway.selectedDates.count * 44)
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        self.selectedDate.frame.size.height = CGFloat(SelectedDatesTimeAway.selectedDates.count * 44)
        self.tableView.contentSize.height = self.originalHeight + self.selectedDate.frame.size.height
        self.tableView.setNeedsDisplay()
        self.tableView.setNeedsLayout()
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        let theDate = date.date
        SelectedDatesTimeAway.selectedDates.append(theDate)
        print(SelectedDatesTimeAway.selectedDates.count)
        let tbc = self.childViewControllers[0] as! UITableViewController
        tbc.preferredContentSize.height = CGFloat ( SelectedDatesTimeAway.selectedDates.count * 44 )
        print(tbc.preferredContentSize.height)
        tbc.tableView.reloadData()
    }
    
    func calendarDidPageToDate(date: Moment) {
        print(date)
    }
    
}