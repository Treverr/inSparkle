//
//  EmployeeSelectionTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class EmployeeSelectionChemCheckoutTableViewController: UITableViewController {
    
    var employees = [Employee]()
    var selectedEmps = [Employee]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        getServiceEmployees()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return employees.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("empCell")
        let currentEmp = employees[indexPath.row] 
        
        cell?.textLabel?.text = currentEmp.firstName.capitalizedString + " " + currentEmp.lastName.capitalizedString
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let selected = employees[indexPath.row]
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            selectedEmps.append(selected)
            print(selectedEmps)
        } else  {
            cell.accessoryType = .None
            selectedEmps.removeAtIndex(selectedEmps.indexOf(selected)!)
            print(selectedEmps)
        }
        
    }
    
    func getServiceEmployees() {
        let query = Employee.query()
        query?.findObjectsInBackgroundWithBlock({ (emps : [PFObject]?, error : NSError?) in
            if error == nil {
                for emp in emps! {
                    let theEmp = emp as! Employee
                    self.employees.append(theEmp)
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ChemCheckoutPDFReportTemplateViewController
        vc.theEmployees = selectedEmps
    }

}
