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
            cell.fullDaySwitch.addTarget(self, action: #selector(SelectedDatesTableViewController.notFullDay(_:)), forControlEvents: .ValueChanged)
            cell.hoursTextField.text = String(8)
            cell.hoursTextField.tag = (indexPath.row - 1)
            cell.hoursTextField.userInteractionEnabled = false
            cell.hoursTextField.delegate = self
            
            return cell
        }
    }
    
    func notFullDay(sender : UISwitch) {
        _ = sender.tag
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag + 1, inSection: 0)) as! SelectedDatesTableViewCell
        
        if sender.on {
            cell.hoursTextField.userInteractionEnabled = false
            cell.hoursTextField.text = String(8)
            cell.hoursTextField.resignFirstResponder()
        } else {
            cell.hoursTextField.userInteractionEnabled = true
            cell.hoursTextField.text = nil
            cell.hoursTextField.becomeFirstResponder()
        }
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

extension SelectedDatesTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        var total : Double = 0
        if !textField.text!.isEmpty {
            let rounded = round(Double(textField.text!)! * 2) / 2
            textField.text = String(rounded)
            
            var cells = self.tableView.visibleCells
            cells.removeFirst()
            
            for cell in cells {
                let theCell = cell as! SelectedDatesTableViewCell
                total = total + Double(theCell.hoursTextField.text!)!
            }
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateTotalNumberOfHours", object: total)
        } else {
            textField.text = String(8)
        }
    }
    
}
