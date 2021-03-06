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
    
    var employeeVacationHours : Double!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimeAwayRequestTableViewController.updateTotalNumberOfHours), name: NSNotification.Name(rawValue: "UpdateTotalNumberOfHours"), object: nil)
        
        submitButton.isEnabled = false
        submitButton.tintColor = UIColor.lightGray
        
        self.navigationItem.title = "Time Away Request"
        
        originalHeight = self.tableView.contentSize.height
        
        calendarView.delegate = self
        
        self.selectedDate.frame.size.height = CGFloat((SelectedDatesTimeAway.selectedDates.count * 44) + 26)
        
        self.navigationController?.isToolbarHidden = false
        
        let vtQuery = VacationTime.query()
        vtQuery?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        do {
            vacationTime = try vtQuery?.getFirstObject() as! VacationTime
            
            vacationHours.text = String(vacationTime.hoursLeft + vacationTime.hoursPending) + " hours"
            
            employeeVacationHours = vacationTime.hoursLeft
            
        } catch { }

    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
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
    
    @IBAction func submitTimeAway(_ sender: AnyObject) {
        
        if unpaidCell.accessoryType != .checkmark && vacationCell.accessoryType != .checkmark {
            let error = UIAlertController(title: "Error", message: "Please select a type of time away.", preferredStyle: .alert)
            let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            error.addAction(okayButton)
            self.present(error, animated: true, completion: nil)
            
        } else {
            totalHours = 0.0
            let tbc = self.childViewControllers[0] as! UITableViewController
            var cells = tbc.tableView.visibleCells
            var timeCardVacation : [String : String] = [:]
            cells.removeFirst()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            dateFormatter.timeZone = SparkleTimeZone.timeZone
            
            for cell in cells {
                let theCell = cell as! SelectedDatesTableViewCell
                totalHours = totalHours + Double(theCell.hoursTextField.text!)!
                timeCardVacation[theCell.dateLabel.text!] = theCell.hoursTextField.text!
            }
            
            let timeAway = TimeAwayRequest()
            SelectedDatesTimeAway.selectedDates.sort()
            timeAway.datesRequested = SelectedDatesTimeAway.selectedDates as NSArray!
            timeAway.requestDate = Date()
            
            if unpaidCell.accessoryType == .checkmark {
                timeAway.type = "Unpaid"
            }
            if vacationCell.accessoryType == .checkmark {
                timeAway.type = "Vacation"
                
                print(vacationTime)
                vacationTime.hoursPending = vacationTime.hoursPending + self.totalHours
                vacationTime.hoursLeft = vacationTime.issuedHours - vacationTime.hoursPending
                vacationTime.saveInBackground()
                
            }
            
            timeAway.status = "Pending"
            timeAway.hours = Double(self.totalHours)
            timeAway.timeCardDictionary = timeCardVacation as NSDictionary
            timeAway.employee = EmployeeData.universalEmployee
            
            if self.totalHours > employeeVacationHours && timeAway.type == "Vacation" {
                let notEnoughTime = UIAlertController(title: "Insufficent Vacation Time", message: "You do not have enough vacation time, if you have pending vacation requests please cancel, reduce your request amount, or select 'Unpaid' for this request.", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                notEnoughTime.addAction(okayButton)
                self.present(notEnoughTime, animated: true, completion: nil)
                
            } else {
                timeAway.saveInBackground { (success : Bool, error : Error?) in
                    if success {
                        let name = EmployeeData.universalEmployee.firstName + " " + EmployeeData.universalEmployee.lastName
                        var timeAwayType = timeAway.type
                        if timeAwayType == "Unpaid" {
                            timeAwayType = "Unpaid Time Away"
                        }
//                        CloudCode.SendNotificationOfNewTimeAwayRequest(name, type: timeAwayType, date1: SelectedDatesTimeAway.selectedDates.first!, date2: SelectedDatesTimeAway.selectedDates.last!, totalHours: timeAway.hours)
                        let alert = UIAlertController(title: "Submitted", message: "Your Time Away Requset has been submitted. Please check with your manager for any questions. You will be notified via email if the request is approved or returned.", preferredStyle: .alert)
                        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                            self.performSegue(withIdentifier: "exitToSparkleConnect", sender: nil)
                        })
                        alert.addAction(okayButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        print(cell?.accessoryType.rawValue)
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                if vacationCell.accessoryType.rawValue == 0 {
                    vacationCell.accessoryType = .checkmark
                    unpaidCell.accessoryType = .none
                } else {
                    vacationCell.accessoryType = .none
                    unpaidCell.accessoryType = .checkmark
                }
            }
            
            if (indexPath as NSIndexPath).row == 1 {
                if unpaidCell.accessoryType.rawValue == 0 {
                    unpaidCell.accessoryType = .checkmark
                    vacationCell.accessoryType = .none
                } else {
                    unpaidCell.accessoryType = .none
                    vacationCell.accessoryType = .checkmark
                }
            }
        }
    }
    
}

extension TimeAwayRequestTableViewController : CalendarViewDelegate {
    
    func calendarDidSelectDate(_ date: Moment) {
        let theDate = date.date
        if theDate.timeIntervalSince(Date()) > 0 {
            if !SelectedDatesTimeAway.selectedDates.contains(theDate) {
                SelectedDatesTimeAway.selectedDates.append(theDate)
                print(SelectedDatesTimeAway.selectedDates.count)
                let tbc = self.childViewControllers[0] as! UITableViewController
                tbc.preferredContentSize.height = CGFloat ( SelectedDatesTimeAway.selectedDates.count * 44 )
                print(tbc.preferredContentSize.height)
                tbc.tableView.beginUpdates()
                let indexPath = IndexPath(row: SelectedDatesTimeAway.selectedDates.count, section: 0)
                tbc.tableView.insertRows(at: [indexPath], with: .automatic)
                tbc.tableView.endUpdates()
                
                self.updateTotalNumberOfHours()
                
                self.submitButton.isEnabled = true
                self.submitButton.tintColor = Colors.defaultTintColor
            }
        }
    }
    
    func calendarDidPageToDate(_ date: Moment) {
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

public func <(a: Date, b: Date) -> Bool {
    return a.compare(b) == .orderedAscending
}

public func ==(a: Date, b: Date) -> Bool {
    return a.compare(b) == .orderedSame
}
