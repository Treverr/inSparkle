//
//  EmployeeListTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/26/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ManageEmployeeListTableViewController: UITableViewController {
    
    var employeeList : [Employee] = [Employee]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getEmps()
    }
    
    func getEmps() {
        let query = Employee.query()
        query?.findObjectsInBackgroundWithBlock({ (employeeResults : [PFObject]?, error : NSError?) in
            if error == nil {
                for emprRes in employeeResults! {
                    self.employeeList.append(emprRes as! Employee)
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("employeeCell")! as UITableViewCell
        
        let row = indexPath.row
        
        let employeeName = employeeList[row].firstName + " " + employeeList[row].lastName
        
        cell.textLabel?.text = employeeName
        
        return cell
    }

}
