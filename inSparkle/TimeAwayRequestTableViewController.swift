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
import Parse

class TimeAwayRequestTableViewController: UITableViewController {
    
    var originalHeight : CGFloat!
    var totalHours : Double = 0.0
    var vacationTime = VacationTime()
    
    @IBOutlet weak var totalHoursButton: UIBarButtonItem!
    
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var submitButton: UIBarButtonItem!
    @IBOutlet var selectedDate : UIView!
    @IBOutlet var calendarView: CalendarView!
    @IBOutlet var vacationCell: UITableViewCell!
    @IBOutlet var unpaidCell: UITableViewCell!
    @IBOutlet var vacationHours: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTotalNumberOfHours", name: "UpdateTotalNumberOfHours", object: nil)
        
        submitButton.enabled = false
        submitButton.tintColor = UIColor.lightGrayColor()
        
        self.navigationItem.title = "Time Away Request"
        
        originalHeight = self.tableView.contentSize.height
        
        calendarView.delegate = self
        
        self.selectedDate.frame.size.height = CGFloat((SelectedDatesTimeAway.selectedDates.count * 44) + 26)
        
        self.navigationController?.toolbarHidden = false
        
        let vtQuery = VacationTime.query()
        vtQuery?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        do {
            vacationTime = try vtQuery?.getFirstObject() as! VacationTime
            
            vacationHours.text = String(vacationTime.hoursLeft + vacationTime.hoursPending) + " hours"
            
        } catch { }

    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        self.selectedDate.frame.size.height = CGFloat((SelectedDatesTimeAway.selectedDates.count * 44) + 26)
        self.tableView.contentSize.height = (self.originalHeight + 198) + self.selectedDate.frame.size.height
        self.tableView.layoutIfNeeded()
    }
    
    func updateTotalNumberOfHours() {
        self.totalHours = 0.0
        let tbc = self.childViewControllers[0] as! UITableViewController
        var cells = tbc.tableView.visibleCells
        cells.removeFirst()
        
        for cell in cells {
            let theCell = cell as! SelectedDatesTableViewCell
            totalHours = totalHours + Double(theCell.hoursTextField.text!)!
        }
        
        self.totalHoursButton.title = "Total Hours: " + String(totalHours)
        
    }
    
    @IBAction func submitTimeAway(sender: AnyObject) {
        
        
        if unpaidCell.accessoryType != .Checkmark && vacationCell.accessoryType != .Checkmark {
            let error = UIAlertController(title: "Error", message: "Please select a type of time away.", preferredStyle: .Alert)
            let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            error.addAction(okayButton)
            self.presentViewController(error, animated: true, completion: nil)
        } else {
            totalHours = 0.0
            let tbc = self.childViewControllers[0] as! UITableViewController
            var cells = tbc.tableView.visibleCells
            var timeCardVacation : [String : String] = [:]
            cells.removeFirst()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            
            for cell in cells {
                let theCell = cell as! SelectedDatesTableViewCell
                totalHours = totalHours + Double(theCell.hoursTextField.text!)!
                timeCardVacation[theCell.dateLabel.text!] = theCell.hoursTextField.text!
            }
            
            let timeAway = TimeAwayRequest()
            SelectedDatesTimeAway.selectedDates.sortInPlace()
            timeAway.datesRequested = SelectedDatesTimeAway.selectedDates
            timeAway.requestDate = NSDate()
            
            if unpaidCell.accessoryType == .Checkmark {
                timeAway.type = "Unpaid"
            }
            if vacationCell.accessoryType == .Checkmark {
                timeAway.type = "Vacation"
                
                print(vacationTime)
                vacationTime.hoursPending = vacationTime.hoursPending + self.totalHours
                vacationTime.hoursLeft = vacationTime.issuedHours - vacationTime.hoursPending
                vacationTime.saveInBackground()
                
            }
            
            timeAway.status = "Pending"
            timeAway.hours = Double(self.totalHours)
            timeAway.timeCardDictionary = timeCardVacation
            timeAway.employee = EmployeeData.universalEmployee
            
            timeAway.saveInBackgroundWithBlock { (success : Bool, error : NSError?) in
                if success {
                    let alert = UIAlertController(title: "Submitted", message: "Your Time Away Requset has been submitted. Please check with your manager for any questions. You will be notified via email if the request is approved or returned.", preferredStyle: .Alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                        self.performSegueWithIdentifier("exitToSparkleConnect", sender: nil)
                    })
                    alert.addAction(okayButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(cell?.accessoryType.rawValue)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if vacationCell.accessoryType.rawValue == 0 {
                    vacationCell.accessoryType = .Checkmark
                    unpaidCell.accessoryType = .None
                } else {
                    vacationCell.accessoryType = .None
                    unpaidCell.accessoryType = .Checkmark
                }
            }
            
            if indexPath.row == 1 {
                if unpaidCell.accessoryType.rawValue == 0 {
                    unpaidCell.accessoryType = .Checkmark
                    vacationCell.accessoryType = .None
                } else {
                    unpaidCell.accessoryType = .None
                    vacationCell.accessoryType = .Checkmark
                }
            }
        }
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(date: Moment) {
        let theDate = date.date
        if theDate.timeIntervalSinceDate(NSDate()) > 0 {
            if !SelectedDatesTimeAway.selectedDates.contains(theDate) {
                SelectedDatesTimeAway.selectedDates.append(theDate)
                print(SelectedDatesTimeAway.selectedDates.count)
                let tbc = self.childViewControllers[0] as! UITableViewController
                tbc.preferredContentSize.height = CGFloat ( SelectedDatesTimeAway.selectedDates.count * 44 )
                print(tbc.preferredContentSize.height)
                tbc.tableView.beginUpdates()
                let indexPath = NSIndexPath(forRow: SelectedDatesTimeAway.selectedDates.count, inSection: 0)
                tbc.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                tbc.tableView.endUpdates()
                
                self.updateTotalNumberOfHours()
                
                self.submitButton.enabled = true
                self.submitButton.tintColor = Colors.defaultTintColor
            }
        }
    }
    
    func calendarDidPageToDate(date: Moment) {
        switch date.month {
        case 1:
            monthLabel.text = "January"
        case 2:
            monthLabel.text = "February"
        case 3:
            monthLabel.text = "March"
        case 4:
            monthLabel.text = "April"
        case 5:
            monthLabel.text = "May"
        case 6:
            monthLabel.text = "June"
        case 7:
            monthLabel.text = "July"
        case 8:
            monthLabel.text = "August"
        case 9:
            monthLabel.text = "September"
        case 10:
            monthLabel.text = "October"
        case 11:
            monthLabel.text = "November"
        case 12:
            monthLabel.text = "December"
        default:
            break
        }
    }
    
}

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == .OrderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == .OrderedSame
}

extension NSDate : Comparable {}