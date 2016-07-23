//
//  EmployeeTimeAwayRequestsTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/3/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class EmployeeTimeAwayRequestsTableViewController: UITableViewController {
    
    var employee : Employee!
    var requests : [TimeAwayRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEmployeePending()
        
        self.navigationItem.title = "Pending Time Away Requests"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("returnToMainTimeAway"), name: "returnToMainTimeAway", object: nil)
        
    }
    
    func returnToMainTimeAway() {
        self.requests.removeAll()
        self.getEmployeePending()
    }
    
    func getEmployeePending() {
        let timeAwayQuery = TimeAwayRequest.query()
        timeAwayQuery?.whereKey("employee", equalTo: self.employee)
        timeAwayQuery?.whereKey("status", equalTo: "Pending")
        timeAwayQuery?.findObjectsInBackgroundWithBlock({ (req : [PFObject]?, error : NSError?) in
            if error == nil {
                self.requests = req as! [TimeAwayRequest]
                self.tableView.reloadData()
                if self.requests.count == 0 {
                    self.performSegueWithIdentifier("returnToMainTimeAway", sender: nil)
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dateCell")! as! UITableViewCell
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        var dates : String = ""
        let datesArray = self.requests[indexPath.row].datesRequested
        var onDate : Int = 0
        
        for date in datesArray {
            dates = dates + "\n" + dateFormatter.stringFromDate(datesArray[onDate] as! NSDate)
            onDate = onDate + 1
        }
        
        print(dates)
        
        cell.textLabel?.text = dateFormatter.stringFromDate(datesArray.firstObject as! NSDate) + " - " + dateFormatter.stringFromDate(datesArray.lastObject as! NSDate)
        cell.detailTextLabel?.text = self.requests[indexPath.row].type
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let row = self.tableView.indexPathForSelectedRow?.row
            let vc = segue.destinationViewController as! UINavigationController
            let reqVC = vc.viewControllers.first as! TimeAwayDetailTableViewController
            reqVC.request = self.requests[row!]
            reqVC.employee = self.employee
        }
    }
    
}
