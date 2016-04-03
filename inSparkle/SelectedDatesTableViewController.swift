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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize.height = CGFloat( (SelectedDatesTimeAway.selectedDates.count * 44) + 26 )
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(SelectedDatesTimeAway.selectedDates.count)
        return SelectedDatesTimeAway.selectedDates.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("headerCell")

            return cell!
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("dateCell")! as! SelectedDatesTableViewCell
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
            
            cell.dateLabel.text = dateFormatter.stringFromDate(SelectedDatesTimeAway.selectedDates[(indexPath.row - 1)])
            cell.fullDaySwitch.setOn(true, animated: false)
            cell.fullDaySwitch.tag = (indexPath.row - 1)
            cell.fullDaySwitch.addTarget(self, action: "notFullDay:", forControlEvents: .ValueChanged)
            cell.hoursTextField.text = String(8)
            cell.hoursTextField.tag = (indexPath.row - 1)
            cell.hoursTextField.userInteractionEnabled = false
            
            return cell
        }
    }
    
    func notFullDay(sender : UISwitch) {
    
        let tag = sender.tag
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag + 1, inSection: 0)) as! SelectedDatesTableViewCell
        
        cell.hoursTextField.userInteractionEnabled = true
        cell.hoursTextField.text = nil
        cell.hoursTextField.becomeFirstResponder()
        
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 26
        } else {
            return 44
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        SelectedDatesTimeAway.selectedDates = []
    }
    
}
