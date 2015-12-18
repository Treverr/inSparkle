//
//  TimeCardManageEmployeeListTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TimeCardManageEmployeeListTableViewController: UITableViewController {
    
    var employees = [Employee]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Select an Employee..."
        
        getEmployees()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getEmployees() {
        let query = Employee.query()
        query?.orderByAscending("firstName")
        query?.findObjectsInBackgroundWithBlock({ (emps : [PFObject]?, error :NSError?) -> Void in
            for emp in emps! {
               self.employees.append(emp as! Employee)
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("employeeCell")
        let firstName = employees[indexPath.row].valueForKey("firstName") as! String
        let lastName = employees[indexPath.row].valueForKey("lastName") as! String
        
        cell?.textLabel?.text = firstName + " " + lastName
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let employee = employees[indexPath.row]
        print(employee)
        let employeeName = employee.firstName + " " + employee.lastName
        
        AddEditEmpTimeCard.employeeEditing = employeeName
        AddEditEmpTimeCard.employeeEditingObject = employee
    
    }
    

}
