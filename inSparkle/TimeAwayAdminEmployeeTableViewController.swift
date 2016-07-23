//
//  TimeAwayAdminEmployeeTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/3/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TimeAwayAdminEmployeeTableViewController: UITableViewController {
    
    var employees : [Employee] = []
    var employeeIDs : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Pending Time Away Requests"
        getEmployeesWithTimeAwayRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func getEmployeesWithTimeAwayRequest() {
        let timeAway = TimeAwayRequest.query()
        timeAway?.whereKey("status", equalTo: "Pending")
        timeAway?.findObjectsInBackgroundWithBlock({ (requests : [PFObject]?, error :NSError?) in
            for req in requests! {
                let request = req as! TimeAwayRequest
                let employee = request.employee
                do {
                    try employee.fetch()
                    print(employee)
                    if !self.employeeIDs.contains(employee.objectId!) {
                         self.employees.append(employee)
                        self.employeeIDs.append(employee.objectId!)
                        self.tableView.reloadData()
                    }
                } catch { }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("employeeCell")! as UITableViewCell
        
        cell.textLabel?.text = employees[indexPath.row].firstName + " " + employees[indexPath.row].lastName
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "employeeDetail" {
            let path = self.tableView.indexPathForSelectedRow
            let employee = self.employees[path!.row]
            
            let sb = self.storyboard!
            let vc = segue.destinationViewController as! EmployeeTimeAwayRequestsTableViewController
            vc.employee = employee
        }
    }

}
