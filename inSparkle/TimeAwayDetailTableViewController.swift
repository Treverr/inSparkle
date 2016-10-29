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
    
     var datesArray : [Date] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        requestedDates.textContainerInset = UIEdgeInsetsMake(-15, -4, 0, 0)
        
        self.navigationItem.title = "Pending " + self.request.type + " Request"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        employeeName.text! = self.employee.firstName + " " + self.employee.lastName
        dateRequested.text = dateFormatter.string(from: self.request.requestDate as Date)
        
        var dates : String = ""
        self.datesArray = self.request.datesRequested as! [Date]
        var onDate : Int = 0
        
        for date in datesArray {
            dates = dates + "\n" + dateFormatter.string(from: datesArray[onDate])
            onDate = onDate + 1
        }
        
        requestedDates.text! = dates
        
        let vacaTimeQuery = VacationTime.query()
        vacaTimeQuery?.whereKey("employee", equalTo: self.employee)
        vacaTimeQuery?.getFirstObjectInBackground(block: { (employeeVaca : PFObject?, error : Error?) in
            if error == nil {
                self.empVaca = employeeVaca as! VacationTime
                self.hoursAlloted.text! = String(self.empVaca.issuedHours)
                self.hoursPending.text! = String(self.empVaca.hoursPending) + " (includes current request)"
                self.hoursRemaining.text! = String(self.empVaca.hoursLeft) + " (includes pending requests)"
            }
        })
    }
    @IBAction func closeButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func approveAction(_ sender: AnyObject) {
        self.request.status = "Approved"
        self.request.saveInBackground { (success : Bool, error : Error?) in
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
                
                var allDates = self.request.timeCardDictionary.allKeys as! [String]
                allDates.sort()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d/yy"
                
                for date in allDates {
                    let vacaTime = VacationTimePunch()
                    vacaTime.employee = self.employee
                    vacaTime.vacationDate = dateFormatter.date(from: date)
                    vacaTime.vacationHours = (self.request.timeCardDictionary[date] as! NSString).doubleValue
                    vacaTime.relationTimeAwayRequest = self.request
                    vacaTime.saveInBackground()
                }
                
            }
            
            if self.request.type == "Unpaid" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                
                var dates : String? = nil
                self.datesArray = self.request.datesRequested as! [Date]
                self.datesArray.sort()
                var onDate : Int = 0
                
                for date in datesArray {
                    if dates == nil {
                        dates = dateFormatter.string(from: date)
                        onDate = onDate + 1
                    } else {
                        dates = dates! + ", " + dateFormatter.string(from: datesArray[onDate])
                        onDate = onDate + 1
                    }
                }
//                CloudCode.SendUnpaidTimeAwayApprovedEmail(empEmail!, dates: dates!)
            }
            
        } catch {
            
        }
        
        self.dismiss(animated: true) { 
            NotificationCenter.default.post(name: Notification.Name(rawValue: "returnToMainTimeAway"), object: nil)
        }
    }
    
    @IBAction func declineAction(_ sender: AnyObject) {
        self.request.status = "Declined"
        self.request.saveInBackground { (success : Bool, error : Error?) in
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
//            CloudCode.SendReturnTimeAway(empEmail!, date1: self.datesArray.first!, date2: self.datesArray.last!, type: self.request.type!)
        } catch {
            
        }
        
        
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "returnToMainTimeAway"), object: nil)
        }
    }

 }
