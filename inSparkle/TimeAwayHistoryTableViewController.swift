//
//  TimeAwayHistoryTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/5/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TimeAwayHistoryTableViewController: UITableViewController {
    
    var returnedRequsts : [TimeAwayRequest] = []
    var history : [TimeAwayRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getReturnedRequests()
        getOtherHistory()
        
        self.navigationItem.title = "Time Away History"
        self.navigationController?.toolbarHidden = true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows : Int! = nil
        
        if section == 0 {
            numberOfRows = returnedRequsts.count
        }
        if section == 1 {
            numberOfRows = history.count
        }
        
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("statusCell")! as UITableViewCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        
        if indexPath.section == 0 {
            let datesRequested = self.returnedRequsts[indexPath.row].datesRequested as! [NSDate]
            let fromDate = dateFormatter.stringFromDate(datesRequested.first!)
            let toDate = dateFormatter.stringFromDate(datesRequested.last!)
            
            cell.textLabel?.text = fromDate + " - " + toDate
            cell.detailTextLabel?.text = "Returned"
        }
        
        if indexPath.section == 1 {
            let datesRequested = self.history[indexPath.row].datesRequested as! [NSDate]
            let fromDate = dateFormatter.stringFromDate(datesRequested.first!)
            let toDate = dateFormatter.stringFromDate(datesRequested.last!)
            
            cell.textLabel?.text = fromDate + " - " + toDate
            cell.detailTextLabel?.text = self.history[indexPath.row].status
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnString : String! = nil
        
        if section == 0 {
            returnString = "Returned Requests"
        } else if section == 1 {
            returnString = "Request History"
        }
        
        return returnString
    }
    
    func getReturnedRequests() {
        let timeAway = TimeAwayRequest.query()
        timeAway?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        timeAway?.whereKey("status", equalTo: "Declined")
        timeAway?.findObjectsInBackgroundWithBlock({ (requests : [PFObject]?, error : NSError?) in
            if error == nil {
                self.returnedRequsts = requests as! [TimeAwayRequest]
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
            }
        })
    }
    
    func getOtherHistory() {
        let timeAway = TimeAwayRequest.query()
        timeAway?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        timeAway?.whereKey("status", notEqualTo: "Declined")
        timeAway?.findObjectsInBackgroundWithBlock({ (requests : [PFObject]?, error : NSError?) in
            if error == nil {
                self.history = requests as! [TimeAwayRequest]
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let vc = segue.destinationViewController as! TimeAwayHistoryDetailTableViewController
            if indexPath?.section == 0 {
                vc.request = self.returnedRequsts[indexPath!.row]
            } else if indexPath?.section == 1 {
                vc.request = self.history[indexPath!.row]
            }
        }
    }
    
}
