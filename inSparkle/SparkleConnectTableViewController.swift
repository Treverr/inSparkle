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
        
        setupNavigationbar()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if EmployeeData.universalEmployee != nil {
            let user = EmployeeData.universalEmployee as! Employee
            let emply = EmployeeData.universalEmployee
            self.employeeNameLabel.text = emply!.firstName + " " + emply!.lastName
            var theRole : Role?
            let roleType = user.objectForKey("roleType") as! Role
            
            roleType.fetchInBackgroundWithBlock({ (role : PFObject?, error : NSError?) in
                if error == nil {
                    theRole = role as! Role
                    self.roleLabel.text = theRole?.roleName
                }
            })

        } else {
            let user = PFUser.currentUser()?.objectForKey("employee") as! Employee
            var emply : Employee?
            var theRole : Role?
            user.fetchInBackgroundWithBlock { (employee : PFObject?, error : NSError?) in
                if error == nil {
                    emply = employee as! Employee
                    self.employeeNameLabel.text = emply!.firstName + " " + emply!.lastName
                }
            }
            
            print(user)
            
            let roleType = user.objectForKey("roleType") as! Role
            
            roleType.fetchInBackgroundWithBlock({ (role : PFObject?, error : NSError?) in
                if error == nil {
                    theRole = role as! Role
                    self.roleLabel.text = theRole?.roleName
                }
            })
        }
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    @IBAction func exitTimeAway(segue : UIStoryboardSegue) {
        
    }
}
