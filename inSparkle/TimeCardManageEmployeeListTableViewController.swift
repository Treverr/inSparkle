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
        
        self.navigationController?.setupNavigationbar(self.navigationController!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getEmployees() {
        let query = Employee.query()
        query?.order(byAscending: "firstName")
        query?.findObjectsInBackground(block: { (emps : [PFObject]?, error :Error?) -> Void in
            for emp in emps! {
               self.employees.append(emp as! Employee)
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell")
        let firstName = employees[(indexPath as NSIndexPath).row].value(forKey: "firstName") as! String
        let lastName = employees[(indexPath as NSIndexPath).row].value(forKey: "lastName") as! String
        
        cell?.textLabel?.text = firstName + " " + lastName
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employee = employees[(indexPath as NSIndexPath).row]
        print(employee)
        let employeeName = employee.firstName + " " + employee.lastName
        
        AddEditEmpTimeCard.employeeEditing = employeeName
        AddEditEmpTimeCard.employeeEditingObject = employee
    
    }
    

}
