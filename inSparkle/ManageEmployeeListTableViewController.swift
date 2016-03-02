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
    var selectedEmployee : Employee!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        
        self.navigationItem.title = "Select Employee"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getEmps()
    }
    
    func getEmps() {
        self.employeeList.removeAll()
        let query = Employee.query()
        
        query?.includeKey("userPointer")
        query?.includeKey("roleType")
        query?.orderByDescending("active")
        query?.orderByAscending("firstName")
        query?.findObjectsInBackgroundWithBlock({ (employeeResults : [PFObject]?, error : NSError?) in
            if error == nil {
                for emprRes in employeeResults! {
                    self.employeeList.append(emprRes as! Employee)
                    self.tableView.reloadData()
                }
                
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
        
        if employeeList[row].active {
            cell.textLabel?.text = employeeName
        } else {
            cell.textLabel?.text = employeeName
            cell.textLabel?.font = UIFont.italicSystemFontOfSize(UIFont.systemFontSize())
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        
        
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let row = self.tableView.indexPathForSelectedRow?.row
        let selected = employeeList[row!] as! Employee
        
        self.selectedEmployee = selected
        
        let dest = segue.destinationViewController as! EmployeeDataTableViewController
        dest.employeeObject = self.selectedEmployee
    }

    @IBAction func dismissAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
}
