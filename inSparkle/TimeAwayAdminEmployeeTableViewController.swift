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
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getEmployeesWithTimeAwayRequest() {
        let timeAway = TimeAwayRequest.query()
        timeAway?.whereKey("status", equalTo: "Pending")
        timeAway?.findObjectsInBackground(block: { (requests : [PFObject]?, error :Error?) in
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "employeeCell")! as UITableViewCell
        
        cell.textLabel?.text = employees[(indexPath as NSIndexPath).row].firstName + " " + employees[(indexPath as NSIndexPath).row].lastName
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "employeeDetail" {
            let path = self.tableView.indexPathForSelectedRow
            let employee = self.employees[(path! as NSIndexPath).row]
            
            let sb = self.storyboard!
            let vc = segue.destination as! EmployeeTimeAwayRequestsTableViewController
            vc.employee = employee
        }
    }

}
