//
//  SelectedDatesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import SwiftMoment

class SelectedDatesTableViewController: UITableViewController {
    
    var selectedDates : [NSDate]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
        
            self.preferredContentSize.height = CGFloat( self.selectedDates.count * 44 )
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dateCell")! as UITableViewCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        cell.textLabel?.text! = dateFormatter.stringFromDate(selectedDates[indexPath.row])
        
        return cell
    }

}
