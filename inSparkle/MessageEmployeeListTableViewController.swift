//
//  MessageEmployeeListTableViewController.swift
//  
//
//  Created by Trever on 12/28/15.
//
//

import UIKit
import Parse

class MessageEmployeeListTableViewController: UITableViewController {
    
    var employees = [Employee]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEmployees()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("empCell")
        
        let firstName = employees[indexPath.row].firstName
        let lastName = employees[indexPath.row].lastName
        
        cell?.textLabel?.text = firstName + " " + lastName
        
        return cell!
    }
    
    func getEmployees() {
        let emp = Employee.query()
        emp?.findObjectsInBackgroundWithBlock({ (emps : [PFObject]?, error : NSError?) -> Void in
            if error == nil && emps != nil {
                print(emps)
                for emp in emps! {
                    self.employees.append(emp as! Employee)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath = self.tableView.indexPathForSelectedRow
        
        let selectedEmployee = employees[indexPath!.row]
        
        let vc = segue.destinationViewController as! ComposeMessageTableViewController
        
        vc.selectedEmployee = selectedEmployee
        
    }
    
}
