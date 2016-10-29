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
    
    override func viewWillAppear(_ animated: Bool) {
        
        getServiceEmployees()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return employees.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "empCell")
        let currentEmp = employees[(indexPath as NSIndexPath).row] 
        
        cell?.textLabel?.text = currentEmp.firstName.capitalized + " " + currentEmp.lastName.capitalized
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        let selected = employees[(indexPath as NSIndexPath).row]
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            selectedEmps.append(selected)
            print(selectedEmps)
        } else  {
            cell.accessoryType = .none
            selectedEmps.remove(at: selectedEmps.index(of: selected)!)
            print(selectedEmps)
        }
        
    }
    
    func getServiceEmployees() {
        let query = Employee.query()
        query?.whereKey("active", equalTo: true)
        query?.findObjectsInBackground(block: { (emps : [PFObject]?, error : Error?) in
            if error == nil {
                for emp in emps! {
                    let theEmp = emp as! Employee
                    self.employees.append(theEmp)
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    

    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
