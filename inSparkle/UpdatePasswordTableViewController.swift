//
//  UpdatePasswordTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/30/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class UpdatePasswordTableViewController: UITableViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswor: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        if passwordTextField.text! == confirmPasswor.text! {
            CloudCode.ChangeUserPassword(PFUser.currentUser()!.username!, newPassword: self.passwordTextField.text!, completion: { (isComplete) in
                if isComplete {
                    let confirm = UIAlertController(title: "Password Changed", message: "Your password has been changed. You will need to re-authenticate with the new password.", preferredStyle: .Alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: { 
                            NSNotificationCenter.defaultCenter().postNotificationName("SignBackIn", object: nil)
                        })
                        
                    })
                    confirm.addAction(okayButton)
                    self.presentViewController(confirm, animated: true, completion: nil)
                }
            })
        } else {
            let error = UIAlertController(title: "Error", message: "Passwords do not match, please try your entry again.", preferredStyle: .Alert)
            let okay = UIAlertAction(title: "Okay.", style: .Default, handler: { (action) in
                self.passwordTextField.text = nil
                self.confirmPasswor.text = nil
                self.confirmPasswor.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            })
            error.addAction(okay)
            self.presentViewController(error, animated: true, completion: nil)
        }
    }
}
