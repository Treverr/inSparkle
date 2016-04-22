//
//  MoreTableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/17/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
class MoreTableViewController: UITableViewController {
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet var adminButton: UIBarButtonItem!
    @IBOutlet var profileLabel: UILabel!
    
    var specialAccess : [String]! = []
    
    override func viewDidLoad() {
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.specialAccess = PFUser.currentUser()?.objectForKey("specialAccess") as! [String]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("signBackIn"), name: "SignBackIn", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        var wasAdmin : Bool!
        var spec : [String] = self.specialAccess
        var origSec = self.tableView.numberOfSections
        
        do {
            try PFUser.currentUser()?.fetch()
            
            self.specialAccess = PFUser.currentUser()?.objectForKey("specialAccess") as! [String]
        } catch { }
        
        if (PFUser.currentUser()?.valueForKey("isAdmin") as! Bool) == false {
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
        } else {
            self.navigationItem.rightBarButtonItem = adminButton
            self.tableView.reloadData()
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (PFUser.currentUser()?.valueForKey("isAdmin") as! Bool) == true {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return specialAccess.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && specialAccess.count > 1 {
            return "Special Access"
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell = self.tableView.dequeueReusableCellWithIdentifier("timeClock")!
            case 1:
                cell = self.tableView.dequeueReusableCellWithIdentifier("chemCheckout")!
            case 2:
                cell = self.tableView.dequeueReusableCellWithIdentifier("pdfLocker")!
            case 3:
                cell = self.tableView.dequeueReusableCellWithIdentifier("sparkleConnect")!
            case 4:
                cell = self.tableView.dequeueReusableCellWithIdentifier("logoutCell")!
            default:
                break
            }
            
        } else {
            if indexPath.section == 1 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("saCell")!
                cell.textLabel?.text = specialAccess[indexPath.row]
                cell.accessoryType = .DisclosureIndicator

                
                switch specialAccess[indexPath.row] {
                case "Manage Users and Employees":
                    cell.imageView?.image = UIImage(named: "Manage Users")
                case "Time Card Management":
                    cell.imageView?.image = UIImage(named: "TimeCard")
                case "Chemical Checkout Reports":
                    cell.imageView?.image = UIImage(named: "Chemical Checkout Report")
                case "Pool Opening Closing Reports":
                    cell.imageView?.image = UIImage(named: "POCReport")
                case "Time Card Reports":
                    cell.imageView?.image = UIImage(named: "Clock")
                default:
                    break
                }
            }
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 4 {
            self.logoutAction(self)
        }
        
        if indexPath.section == 1 {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            switch cell!.textLabel!.text! {
            case "Manage Users and Employees":
                let sb = UIStoryboard(name: "Manage Emps", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("manageEmpsNav") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
            case "Time Card Management":
                let sb = UIStoryboard(name: "TimeCardManagement", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("timeCardManageNav") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
            case "Chemical Checkout Reports":
                let sb = UIStoryboard(name: "ChemicalCheckoutReport", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("chemCheckoutNav") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
            case "Pool Opening Closing Reports":
                let sb = UIStoryboard(name: "POCReport", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("pocReportNav") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
            case "Time Card Reports":
                let sb = UIStoryboard(name: "TimeClockReport", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("timeCardReportNav") as! UINavigationController
                self.presentViewController(vc, animated: true, completion: nil)
            default:
                break
            }
            
        }
        
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func supportAction(sender: AnyObject) {
        Mobihelp.sharedInstance().presentSupport(self)
    }
    
    func setUserName() {
        if EmployeeData.universalEmployee != nil {
            let empl = EmployeeData.universalEmployee as! Employee
            let name = empl.firstName + " " + empl.lastName
            self.profileLabel.text = name
        }
    }
    
    
    
    func signBackIn() {
        PFSession.getCurrentSessionInBackgroundWithBlock { (session : PFSession?, error : NSError?) in
            if error != nil {
                PFUser.logOut()
                let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                let currentUser : PFUser?
                
                currentUser = PFUser.currentUser()
                let currentSession = PFUser.currentUser()?.sessionToken
                
                if (currentUser == nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                }
                
                if (currentUser?.sessionToken == nil) {
                    PFUser.logOut()
                    let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
