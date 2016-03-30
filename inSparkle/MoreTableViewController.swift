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
    
    override func viewDidLoad() {
        setupNavigationbar()
        
        if (PFUser.currentUser()?.valueForKey("isAdmin") as! Bool) == false {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("signBackIn"), name: "SignBackIn", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        setUserName()
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }

    
    @IBAction func supportAction(sender: AnyObject) {
        Mobihelp.sharedInstance().presentSupport(self)
    }
    
    func setUserName() {
        if PFUser.currentUser() != nil {
            let user = PFUser.currentUser()?.objectForKey("employee")
            user?.fetchIfNeededInBackgroundWithBlock({ (employee : PFObject?, error : NSError?) in
                if error == nil {
                    let empl = employee as! Employee
                    let name = empl.firstName + " " + empl.lastName
                    self.profileLabel.text = name
                }
            })
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
                
                if currentUser != nil && currentSession != nil {
                }
                
            }
        }
    }

}
