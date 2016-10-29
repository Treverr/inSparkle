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
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.navigationItem.title = "Select Employee"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getEmps()
    }
    
    func getEmps() {
        self.employeeList.removeAll()
        let query = Employee.query()
        
        query?.includeKey("userPointer")
        query?.includeKey("roleType")
        query?.order(byDescending: "active")
        query?.order(byAscending: "firstName")
        query?.findObjectsInBackground(block: { (employeeResults : [PFObject]?, error : Error?) in
            if error == nil {
                for emprRes in employeeResults! {
                    self.employeeList.append(emprRes as! Employee)
                    self.tableView.reloadData()
                }
                
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell")! as UITableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let employeeName = employeeList[row].firstName + " " + employeeList[row].lastName
        
        print(employeeList[row].active)
        
        if employeeList[row].active {
            cell.textLabel?.text = employeeName
            cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.text = employeeName
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
            cell.textLabel?.textColor = UIColor.lightGray
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let row = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row
        let selected = employeeList[row!] 
        
        self.selectedEmployee = selected
        
        let dest = segue.destination as! EmployeeDataTableViewController
        dest.employeeObject = self.selectedEmployee
    }

    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
