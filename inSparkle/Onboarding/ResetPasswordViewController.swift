//
//  ResetPasswordViewController.swift
//  inSparkle
//
//  Created by Trever on 11/17/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeResetPassword(_ sender : AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(_ sender: AnyObject) {
        let email = self.emailField.text
        
        if email == "" {
            let alert = UIAlertController(title: "Enter Something", message: "Please enter your email address on file." , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let finalEmail = email?.trimmingCharacters(in: CharacterSet.whitespaces)
            
            PFUser.requestPasswordResetForEmail(inBackground: finalEmail!)
            
            let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + finalEmail! + ".", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
