//
//  TimeAwayDetailTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/4/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TimeAwayDetailTableViewController: UITableViewController {

    @IBOutlet var employeeName: UILabel!
    @IBOutlet var dateRequested: UILabel!
    @IBOutlet var requestedDates: UITextView!
    @IBOutlet var hoursAlloted: UILabel!
    @IBOutlet var hoursPending: UILabel!
    @IBOutlet var hoursRemaining: UILabel!
    
    var request = TimeAwayRequest()
    var employee = Employee()
    var empVaca = VacationTime()
    
     var datesArray : [NSDate] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestedDates.textContainerInset = UIEdgeInsetsMake(-15, -4, 0, 0)
        
        self.navigationItem.title = "Pending " + self.request.type + " Request"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        employeeName.text! = self.employee.firstName + " " + self.employee.lastName
        dateRequested.text = dateFormatter.stringFromDate(self.request.requestDate)
        
        var dates : String = ""
        self.datesArray = self.request.datesRequested as! [NSDate]
        var onDate : Int = 0
        
        for date in datesArray {
            dates = dates + "\n" + dateFormatter.stringFromDate(datesArray[onDate])
            onDate = onDate + 1
        }
        
        requestedDates.text! = dates
        
        let vacaTimeQuery = VacationTime.query()
        vacaTimeQuery?.whereKey("employee", equalTo: self.employee)
        vacaTimeQuery?.getFirstObjectInBackgroundWithBlock({ (employeeVaca : PFObject?, error : NSError?) in
            if error == nil {
                self.empVaca = employeeVaca as! VacationTime
                self.hoursAlloted.text! = String(self.empVaca.issuedHours)
                self.hoursPending.text! = String(self.empVaca.hoursPending) + " (includes current request)"
                self.hoursRemaining.text! = String(self.empVaca.hoursLeft) + " (includes pending requests)"
            }
        })
    }
    
    @IBAction func approveAction(sender: AnyObject) {
        self.request.status = "Approved"
        self.request.saveInBackgroundWithBlock { (success : Bool, error : NSError?) in
            if success {
                
            }
        }
        
        var empEmail : String?
        
        let user = self.employee.userPoint
        do {
            try user?.fetch()
            empEmail = user?.email!
            if self.request.type == "Vacation" {
                CloudCode.SendVacationApprovedEmail(empEmail!, date1: self.datesArray.first!, date2: self.datesArray.last!)
                self.empVaca.issuedHours = (self.empVaca.issuedHours - self.request.hours)
                self.empVaca.hoursPending = (self.empVaca.hoursPending - self.request.hours)
                self.empVaca.hoursLeft = (self.empVaca.issuedHours - self.empVaca.hoursPending)
                self.empVaca.saveInBackground()
            }
            if self.request.type == "Unpaid" {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .NoStyle
                
                var dates : String? = nil
                self.datesArray = self.request.datesRequested as! [NSDate]
                var onDate : Int = 0
                
                for date in datesArray {
                    if dates == nil {
                        dates = dateFormatter.stringFromDate(date)
                        onDate = onDate + 1
                    } else {
                        dates = dates! + ", " + dateFormatter.stringFromDate(datesArray[onDate])
                        onDate = onDate + 1
                    }
                }
                CloudCode.SendUnpaidTimeAwayApprovedEmail(empEmail!, dates: dates!)
            }
        } catch {
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func declineAction(sender: AnyObject) {
        self.request.status = "Declined"
        self.request.saveInBackgroundWithBlock { (success : Bool, error : NSError?) in
            if success {
                
            }
        }
        self.empVaca.hoursPending = (self.empVaca.hoursPending - self.request.hours)
        self.empVaca.hoursLeft = (self.empVaca.hoursLeft + self.request.hours)
        self.empVaca.saveInBackground()
        
        var empEmail : String?
        
        let user = self.employee.userPoint
        do {
            try user?.fetch()
            empEmail = user?.email!
            CloudCode.SendReturnTimeAway(empEmail!, date1: self.datesArray.first!, date2: self.datesArray.last!, type: self.request.type!)
        } catch {
            
        }
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

 }
