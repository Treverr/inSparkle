//
//  ConfirmCalViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import CalendarView
import SwiftMoment

class ConfirmCalViewController: UIViewController {

    @IBOutlet var calendar: CalendarView!
    
    var shouldDismiss : Bool = false
    
    var date : Moment! {
        didSet {
            title = date.format("MMMM d, yyyy")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()

        date = moment()
        calendar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension ConfirmCalViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        self.shouldDismiss = true
        self.date = date
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("NotifyConfirmScreenUpdateLabel", object: date.format("MMMM d, yyyy"))
    }
    
    func calendarDidPageToDate(date: Moment) {
        title = date.format("MMMM yyyy")
    }
    
}