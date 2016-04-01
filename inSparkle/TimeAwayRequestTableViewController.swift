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

    @IBOutlet var calendarView: CalendarView!
    
    var selectedDates : [Moment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnInt = 0
        
        if section == 0 {
            returnInt = 2
        }
        if section == 1 {
            returnInt = 1
        }
        
        if section == 2 {
            print(selectedDates.count)
           returnInt = selectedDates.count
        }
        
        return returnInt
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        selectedDates.append(date)
        print(selectedDates)
        let section = NSIndexSet(index: 2)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(section, withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    func calendarDidPageToDate(date: Moment) {
        print(date)
    }
    
}