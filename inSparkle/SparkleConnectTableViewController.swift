//
//  SparkleConnectTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/29/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class SparkleConnectTableViewController: UITableViewController {
    
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if EmployeeData.universalEmployee != nil {
            let user = EmployeeData.universalEmployee as Employee
            let emply = EmployeeData.universalEmployee
            self.employeeNameLabel.text = emply!.firstName + " " + emply!.lastName
            var theRole : Role?
            let roleType = user.object(forKey: "roleType") as! Role
            
            roleType.fetchInBackground(block: { (role : PFObject?, error : Error?) in
                if error == nil {
                    theRole = role as! Role
                    self.roleLabel.text = theRole?.roleName
                }
            })

        } else {
            let user = PFUser.current()?.object(forKey: "employee") as! Employee
            var emply : Employee?
            var theRole : Role?
            user.fetchInBackground { (employee : PFObject?, error : Error?) in
                if error == nil {
                    emply = employee as! Employee
                    self.employeeNameLabel.text = emply!.firstName + " " + emply!.lastName
                }
            }
            
            print(user)
            
            let roleType = user.object(forKey: "roleType") as! Role
            
            roleType.fetchInBackground(block: { (role : PFObject?, error : Error?) in
                if error == nil {
                    theRole = role as! Role
                    self.roleLabel.text = theRole?.roleName
                }
            })
        }
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitTimeAway(_ segue : UIStoryboardSegue) {
        
    }
}
