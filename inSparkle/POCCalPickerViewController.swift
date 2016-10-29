//
//  POCCalPickerViewController.swift
//  inSparkle
//
//  Created by Trever on 12/15/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import CalendarView
import SwiftMoment

class POCCalPickerViewController: UIViewController {
    
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

extension POCCalPickerViewController : CalendarViewDelegate {

    func calendarDidSelectDate(_ date: Moment) {
        self.date = date
        if POCRunReport.selectedCell == "startDate" {
            POCRunReport.selectedDate = date.format("MMMM d, yyyy")
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyPOCUpdateStartLabel"), object: nil)
        }
        if POCRunReport.selectedCell == "endDate" {
            POCRunReport.selectedDate = date.format("MMMM d, yyyy")
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyPOCUpdateEndLabel"), object: nil)
        }
    }
    
    func calendarDidPageToDate(_ date: Moment) {

        title = date.format("MMMM yyyy")
    
    }
    
}
