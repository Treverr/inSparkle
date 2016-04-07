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

    self.navigationController?.toolbarHidden = false
        
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberToReturn : Int! = nil
        
        switch section {
        case 0:
            numberToReturn = 2
        case 1:
            let dates = self.request.timeCardDictionary.allKeys as! [NSDate]
            numberToReturn = dates.count
        default:
            break
        }
        
        return numberToReturn
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("statusCell") as UITableViewCell!
                cell.detailTextLabel?.text = self.request.status
            }
            if indexPath.row == 1 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("typeCell") as UITableViewCell!
                cell.detailTextLabel?.text = self.request.type
            }
        }
        
        if indexPath.section == 1 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("dateCell") as UITableViewCell!
            let dates = self.request.timeCardDictionary.allKeys
            let currentDate = dates[indexPath.row] as! String
            let dict = self.request.timeCardDictionary as! [String : String]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            
            cell.textLabel?.text = currentDate
            cell.detailTextLabel?.text = dict[currentDate]! + " hours"
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Status:"
        } else {
            return "Dates in Request:"
        }
    }

    @IBAction func cancelRequest(sender: AnyObject) {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to cancel this request? You will need to re-submit", preferredStyle: .Alert)
        let yes = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            var originalStatus = self.request.status
            self.request.status = "Cancelled"
            self.request.saveInBackground()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            
            do {
                try self.request.fetch()
                self.tableView.beginUpdates()
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                var toolbar = self.toolbarItems
                toolbar?.removeAll()
                self.setToolbarItems(toolbar, animated: true)
            } catch {
                
            }
            let cancelQuery = VacationTimePunch.query()
            cancelQuery?.whereKey("relationTimeAwayRequest", equalTo: self.request)
            cancelQuery?.findObjectsInBackgroundWithBlock({ (found : [PFObject]?, error : NSError?) in
                if error == nil {
                    PFObject.deleteAllInBackground(found!)
                }
            })
            
            let vTQuery = VacationTime.query()
            vTQuery?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
            vTQuery?.getFirstObjectInBackgroundWithBlock({ (got : PFObject?, error : NSError?) in
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
                        }
                        obj.saveInBackground()
                    }
                }
            })
        }
        let no = UIAlertAction(title: "Nevermind", style: .Default, handler: nil)
        confirmAlert.addAction(no)
        confirmAlert.addAction(yes)
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
}
