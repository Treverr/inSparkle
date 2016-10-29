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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "empCell")
        
        let firstName = employees[(indexPath as NSIndexPath).row].firstName
        let lastName = employees[(indexPath as NSIndexPath).row].lastName
        
        cell?.textLabel?.text = firstName + " " + lastName
        
        return cell!
    }
    
    func getEmployees() {
        let emp = Employee.query()
        emp?.whereKey("active", equalTo: true)
        emp?.whereKey("messages", equalTo: true)
        emp?.order(byAscending: "lastName")
        emp?.findObjectsInBackground(block: { (emps : [PFObject]?, error : Error?) -> Void in
            if error == nil && emps != nil {
                print(emps)
                for emp in emps! {
                    self.employees.append(emp as! Employee)
                    self.tableView.reloadData()
                    self.preferredContentSize = self.tableView.contentSize
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEmployee = employees[(indexPath as NSIndexPath).row]
        MessagesDataObjects.selectedEmp = selectedEmployee
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = self.tableView.indexPathForSelectedRow
        
        let selectedEmployee = employees[(indexPath! as NSIndexPath).row]
        
        let vc = segue.destination as! ComposeMessageTableViewController
        
        vc.selectedEmployee = selectedEmployee
        
    }
    
}
