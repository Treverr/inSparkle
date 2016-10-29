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
        self.navigationController?.isToolbarHidden = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "statusCell")! as UITableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        
        if (indexPath as NSIndexPath).section == 0 {
            let datesRequested = self.returnedRequsts[(indexPath as NSIndexPath).row].datesRequested as! [Date]
            let fromDate = dateFormatter.string(from: datesRequested.first!)
            let toDate = dateFormatter.string(from: datesRequested.last!)
            
            cell.textLabel?.text = fromDate + " - " + toDate
            cell.detailTextLabel?.text = "Returned"
        }
        
        if (indexPath as NSIndexPath).section == 1 {
            let datesRequested = self.history[(indexPath as NSIndexPath).row].datesRequested as! [Date]
            let fromDate = dateFormatter.string(from: datesRequested.first!)
            let toDate = dateFormatter.string(from: datesRequested.last!)
            
            cell.textLabel?.text = fromDate + " - " + toDate
            cell.detailTextLabel?.text = self.history[(indexPath as NSIndexPath).row].status
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        timeAway?.findObjectsInBackground(block: { (requests : [PFObject]?, error : Error?) in
            if error == nil {
                self.returnedRequsts = requests as! [TimeAwayRequest]
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = IndexSet(integersIn: range.toRange() ?? 0..<0)
                self.tableView.reloadSections(sections, with: .automatic)
            }
        })
    }
    
    func getOtherHistory() {
        let timeAway = TimeAwayRequest.query()
        timeAway?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        timeAway?.whereKey("status", notEqualTo: "Declined")
        timeAway?.findObjectsInBackground(block: { (requests : [PFObject]?, error : Error?) in
            if error == nil {
                self.history = requests as! [TimeAwayRequest]
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = IndexSet(integersIn: range.toRange() ?? 0..<0)
                self.tableView.reloadSections(sections, with: .automatic)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let vc = segue.destination as! TimeAwayHistoryDetailTableViewController
            if (indexPath as NSIndexPath?)?.section == 0 {
                vc.request = self.returnedRequsts[(indexPath! as NSIndexPath).row]
            } else if (indexPath as NSIndexPath?)?.section == 1 {
                vc.request = self.history[(indexPath! as NSIndexPath).row]
            }
        }
    }
    
}
