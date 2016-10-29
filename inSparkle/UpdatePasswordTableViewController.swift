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
    
    @IBAction func saveButton(_ sender: AnyObject) {
        if passwordTextField.text! == confirmPasswor.text! {
            CloudCode.ChangeUserPassword(PFUser.current()!.username!, newPassword: self.passwordTextField.text!, completion: { (isComplete) in
                if isComplete {
                    let confirm = UIAlertController(title: "Password Changed", message: "Your password has been changed. You will need to re-authenticate with the new password.", preferredStyle: .alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: { 
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "SignBackIn"), object: nil)
                        })
                        
                    })
                    confirm.addAction(okayButton)
                    self.present(confirm, animated: true, completion: nil)
                }
            })
        } else {
            let error = UIAlertController(title: "Error", message: "Passwords do not match, please try your entry again.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay.", style: .default, handler: { (action) in
                self.passwordTextField.text = nil
                self.confirmPasswor.text = nil
                self.confirmPasswor.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            })
            error.addAction(okay)
            self.present(error, animated: true, completion: nil)
        }
    }
}
