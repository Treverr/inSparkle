//
//  UserPINViewController.swift
//  inSparkle
//
//  Created by Trever on 2/13/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class UserPINViewController: UIViewController {
    
    var pinString : String = ""
    var employees : [Employee]!
    
    @IBOutlet var pinTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func number1(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "1")
        checkField()
    }
    
    @IBAction func number2(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "2")
        checkField()
        
    }
    
    @IBAction func number3(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "3")
        checkField()
        
    }
    
    @IBAction func number4(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "4")
        checkField()
    }
    
    @IBAction func number5(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "5")
        checkField()
    }
    
    @IBAction func number6(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "6")
        checkField()
    }
    
    @IBAction func number7(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "7")
        checkField()
    }
    
    @IBAction func number8(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "8")
        checkField()
    }
    
    @IBAction func number9(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "9")
        checkField()
    }
    
    @IBAction func number0(_ sender: AnyObject) {
        pinTextField.text = (pinTextField.text! + "• ")
        pinString = (pinString + "0")
        checkField()
    }
    
    func checkField() {
        if pinTextField.text?.characters.count == 8 {
            authenticateEmployee()
        }
    }
    
    @IBAction func deleteButton(_ sender: AnyObject) {
        pinTextField.text = ""
        pinString = ""
    }
    
    func authenticateEmployee() {
        let employeeQuery = Employee.query()
        employeeQuery?.whereKey("active", equalTo: true)
        let pinToCheck = pinString
        employeeQuery?.whereKey("pinNumber", equalTo: pinToCheck)
        employeeQuery?.findObjectsInBackground(block: { (employees : [PFObject]?, error : Error?) in
            if employees?.count != 0 && employees != nil {
                let theEmployee = employees?.first as! Employee
                print(theEmployee)
                let chem = ReportsTableViewController()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }


}

extension UserPINViewController : UITextFieldDelegate {
    
    
}
