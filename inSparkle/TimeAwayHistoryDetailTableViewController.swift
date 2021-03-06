//
//  TimeAwayHistoryDetailTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/6/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TimeAwayHistoryDetailTableViewController: UITableViewController {
    
    var request : TimeAwayRequest!
    @IBOutlet var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

    self.navigationController?.isToolbarHidden = false
        
        if self.request.status == "Cancelled" || self.request.status == "Declined" {
            print(self.request.status)
            var toolbar = self.toolbarItems
            toolbar?.removeAll()
            self.setToolbarItems(toolbar, animated: false)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberToReturn : Int! = nil
        
        switch section {
        case 0:
            numberToReturn = 2
        case 1:
            let dates = self.request.timeCardDictionary.allKeys as! [Date]
            numberToReturn = dates.count
        case 2:
            return 1
        default:
            break
        }
        
        return numberToReturn
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                cell = self.tableView.dequeueReusableCell(withIdentifier: "statusCell") as UITableViewCell!
                cell.detailTextLabel?.text = self.request.status
            }
            if (indexPath as NSIndexPath).row == 1 {
                cell = self.tableView.dequeueReusableCell(withIdentifier: "typeCell") as UITableViewCell!
                cell.detailTextLabel?.text = self.request.type
            }
        }
        
        if (indexPath as NSIndexPath).section == 1 {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "dateCell") as UITableViewCell!
            var dates = self.request.timeCardDictionary.allKeys as! [String]
            dates.sort()
            let currentDate = dates[(indexPath as NSIndexPath).row] 
            let dict = self.request.timeCardDictionary as! [String : String]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            dateFormatter.timeZone = SparkleTimeZone.timeZone
            
            cell.textLabel?.text = currentDate
            cell.detailTextLabel?.text = dict[currentDate]! + " hours"
        }
        
        if (indexPath as NSIndexPath).section == 2 {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "totalCell") as UITableViewCell!
            cell.textLabel?.text = "Total Hours: " + String(self.request.hours)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Status:"
        } else if section == 1 {
            return "Dates in Request:"
        } else {
            return ""
        }
    }

    @IBAction func cancelRequest(_ sender: AnyObject) {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to cancel this request? You will need to re-submit", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            let originalStatus = self.request.status
            self.request.status = "Cancelled"
            self.request.saveInBackground()
            let indexPath = IndexPath(row: 0, section: 0)
            
            do {
                try self.request.fetch()
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                var toolbar = self.toolbarItems
                toolbar?.removeAll()
                self.setToolbarItems(toolbar, animated: true)
            } catch {
                
            }
            let cancelQuery = VacationTimePunch.query()
            cancelQuery?.whereKey("relationTimeAwayRequest", equalTo: self.request)
            cancelQuery?.findObjectsInBackground(block: { (found : [PFObject]?, error : Error?) in
                if error == nil {
                    PFObject.deleteAll(inBackground: found!)
                }
            })
            
            let vTQuery = VacationTime.query()
            vTQuery?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
            vTQuery?.getFirstObjectInBackground(block: { (got : PFObject?, error : Error?) in
                if error == nil {
                    if self.request.type == "Vacation" {
                        let obj = got as! VacationTime
                        if originalStatus == "Pending" {
                            obj.hoursPending = obj.hoursPending - self.request.hours
                            obj.hoursLeft = obj.hoursLeft + self.request.hours
                        }
                        if originalStatus == "Approved" {
                            obj.issuedHours = obj.issuedHours + self.request.hours
                            obj.hoursLeft = obj.issuedHours - obj.hoursPending
                            
                            let name = EmployeeData.universalEmployee.firstName + " " + EmployeeData.universalEmployee.lastName
                            var dates = self.request.datesRequested as! [Date]
                            dates.sort()
                            let firstDate : Date = dates.first!
                            let lastDate : Date = dates.last!
//                            CloudCode.TimeAwayCancelEmail(name, type: self.request.type, date1: firstDate, date2: lastDate, totalHours: self.request.hours)
                        }
                        obj.saveInBackground()
                    }
                }
            })
        }
        let no = UIAlertAction(title: "Nevermind", style: .default, handler: nil)
        confirmAlert.addAction(no)
        confirmAlert.addAction(yes)
        self.present(confirmAlert, animated: true, completion: nil)
    }
}
