//
//  EmployeeDataTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import DropDown

class EmployeeDataTableViewController: UITableViewController {
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var userLoginSwitch: UISwitch!
    @IBOutlet var userNameTextField: UITextField!
    
    @IBOutlet var emailAddressTextField: UITextField!
    @IBOutlet var messagesEnabledSwitch: UISwitch!
    @IBOutlet var adminSwitch: UISwitch!
    @IBOutlet var accessManagerLabel: UILabel!
    @IBOutlet var accessManagerCell: UITableViewCell!
    @IBOutlet var disableEnableEmployee: UIButton!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    var employeeObject : Employee!
    var userObject : PFUser!
    
    var roleDict = [String : Role]()
    var selectedRole : Role?
    var roleDropDown = DropDown()
    
    @IBOutlet var messagesEnabledLabel: UILabel!
    @IBOutlet var adminPrivLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        emailAddressTextField.delegate = self
        
        getRoles()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath != nil {
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
        if employeeObject != nil  {
            firstName.text = employeeObject.firstName
            lastName.text = employeeObject.lastName
            if employeeObject.objectForKey("roleType") != nil {
                employeeObject.objectForKey("roleType")!.fetchInBackgroundWithBlock({ (daRole : PFObject?, error : NSError?) in
                    if error == nil {
                        self.roleLabel.text = daRole!.objectForKey("roleName") as! String
                        self.roleLabel.textColor = UIColor.blackColor()
                    }
                })
            }
            print(employeeObject)
            if employeeObject.userPoint != nil {
                let userID = employeeObject.userPoint!.objectId!
                let query = PFUser.query()
                query?.whereKey("objectId", equalTo: userID)
                query?.getFirstObjectInBackgroundWithBlock({ (userData : PFObject?, error : NSError?) in
                    let userInfo = userData as! PFUser
                    self.userObject = userInfo
                    self.userLoginSwitch.setOn(true, animated: false)
                    self.userNameTextField.text = userInfo.username
                    self.emailAddressTextField.text = userInfo.email
                    if self.employeeObject.userPoint!.objectForKey("isAdmin") as! Bool {
                        self.adminSwitch.setOn(true, animated: false)
                        self.accessManagerLabel.textColor = UIColor.lightGrayColor()
                        self.accessManagerCell.userInteractionEnabled = false
                    } else {
                        
                    }
                    if self.employeeObject.messages {
                        self.messagesEnabledSwitch.setOn(true, animated: false)
                    }
                })
                
            } else {
                userLoginSwitch.setOn(false, animated: false)
                usernameLabel.textColor = UIColor.lightGrayColor()
                emailLabel.textColor = UIColor.lightGrayColor()
                adminPrivLabel.textColor = UIColor.lightGrayColor()
                messagesEnabledLabel.textColor = UIColor.lightGrayColor()
                userNameTextField.userInteractionEnabled = false
                emailAddressTextField.userInteractionEnabled = false
                messagesEnabledSwitch.userInteractionEnabled = false
                adminSwitch.userInteractionEnabled = false
                self.accessManagerLabel.textColor = UIColor.lightGrayColor()
                self.accessManagerCell.userInteractionEnabled = false
                
            }
            if employeeObject.active {
                disableEnableEmployee.setTitle("Disable Employee", forState: .Normal)
            } else {
                disableEnableEmployee.setTitle("Enable Employee", forState: .Normal)
                disableEnableEmployee.setTitleColor(UIColor.blueColor(), forState: .Normal)
            }
        } else {
            self.employeeObject = Employee()
            usernameLabel.textColor = UIColor.lightGrayColor()
            userNameTextField.userInteractionEnabled = false
            emailLabel.textColor = UIColor.lightGrayColor()
            emailAddressTextField.userInteractionEnabled = false
            messagesEnabledLabel.textColor = UIColor.lightGrayColor()
            messagesEnabledSwitch.userInteractionEnabled = false
            adminSwitch.userInteractionEnabled = false
            adminPrivLabel.textColor = UIColor.lightGrayColor()
            accessManagerCell.userInteractionEnabled = false
            accessManagerLabel.textColor = UIColor.lightGrayColor()
            disableEnableEmployee.setTitle("Save", forState: .Normal)
            disableEnableEmployee.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
    }
    
    func getRoles() {
        let query = Role.query()
        query?.findObjectsInBackgroundWithBlock({ (theRoles : [PFObject]?, error : NSError?) in
            if error == nil {
                for role in theRoles! {
                    let roleObj = role as! Role
                    self.roleDict[roleObj.roleName] = roleObj
                }
                self.setupRoleDropDown()
            }
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            print(roleDropDown.show())
            roleDropDown.show()
        }
    }
    
    var roleDropDownArray = [String]()
    
    @IBOutlet var roleCell: UITableViewCell!
    
    func setupRoleDropDown() {
        
        var roles : [String] {
            get {
                return Array(self.roleDict.keys)
            }
        }
        
        print(roles)
        
        roleDropDown.dataSource = roles
        roleDropDown.direction = .Any
        roleDropDown.anchorView = self.roleCell
        roleDropDown.bottomOffset = CGPoint(x: 0, y: roleDropDown.anchorView!.bounds.height)
        roleDropDown.topOffset = CGPoint(x: 0, y: -roleDropDown.anchorView!.bounds.height)
        roleDropDown.dismissMode = .Automatic
        
        roleDropDown.selectionAction = { [unowned self] (index, item) in
            self.roleLabel.text = item
            self.roleLabel.textColor = UIColor.blackColor()
            self.selectedRole = self.roleDict[item]
            print(self.selectedRole)
            self.employeeObject.roleType = self.selectedRole
            self.employeeObject.saveInBackground()
    }
    }

    
    @IBAction func disableEnableEmployeeAction(sender: AnyObject) {
        if disableEnableEmployee.titleLabel?.text == "Disable Employee" {
            let disableAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to disable the employee?", preferredStyle: .Alert)
            let confirmButton = UIAlertAction(title: "Confirm", style: .Destructive, handler: { (action) in
                var userID : String!
                let userQuery = PFUser.query()
                userQuery?.whereKey("employee", equalTo: self.employeeObject)
                userQuery?.findObjectsInBackgroundWithBlock({ (userFound : [PFObject]?, error : NSError?) in
                    if error == nil {
                        if userFound?.count == 1 {
                            userID = userFound?.first?.objectId
                            CloudCode.DeleteUser(userID, completion: { (complete) in
                                if complete {
                                }
                            })
                        }
                    }
                })
                self.employeeObject?.removeObjectForKey("pinNumber")
                self.employeeObject?.active = false
                self.employeeObject.removeObjectForKey("userPointer")
                self.employeeObject.removeObjectForKey("roleType")
                self.employeeObject.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                    if success {
                            self.performSegueWithIdentifier("returnToManageEmp", sender: nil)
                    }
                })
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            disableAlert.addAction(cancelButton)
            disableAlert.addAction(confirmButton)
            self.presentViewController(disableAlert, animated: true, completion: nil)
        }
        
        if disableEnableEmployee.titleLabel?.text == "Save" || disableEnableEmployee.titleLabel?.text == "Enable Employee" {
            if firstName.text!.isEmpty || lastName.text!.isEmpty {
                var missingFields : String!
                if firstName.text!.isEmpty {
                    missingFields = "First Name"
                }
                if lastName.text!.isEmpty {
                    if missingFields == nil {
                        missingFields = "Last Name"
                    } else {
                        missingFields = "First Name & Last Name"
                    }
                }
                let errorAlert = UIAlertController(title: "Check Fields", message: missingFields + " Are missing information. Please check and try again.", preferredStyle: .Alert)
            } else {
                var pinText : UITextField!
                let pinAlert = UIAlertController(title: "PIN Selection", message: "Select a 4-digit PIN", preferredStyle: .Alert)
                pinAlert.addTextFieldWithConfigurationHandler({ (textField) in
                    pinText = textField
                })
                
                let doneButton = UIAlertAction(title: "Done", style: .Default, handler: { (action) in
                    self.verifyPIN(pinText.text!, completion: { (pass) in
                        if pass {
                            if self.employeeObject.objectId == nil {
                                let name = self.firstName.text! + " " + self.lastName.text!
                                let email = self.emailAddressTextField.text!
                                CloudCode.SendWelcomeEmail(name, toEmail: email, emailAddress: email)
                            }
                            self.employeeObject.firstName = self.firstName.text!.capitalizedString
                            self.employeeObject.lastName = self.lastName.text!.capitalizedString
                            self.employeeObject.messages = self.messagesEnabledSwitch.on
                            self.employeeObject.active = true
                            self.employeeObject.pinNumber = "\(pinText!.text!)"
                            if self.selectedRole != nil {
                                self.employeeObject.roleType = self.selectedRole!
                            }
                            print(self.employeeObject)
                            do {
                                try self.employeeObject.save()
                            } catch {
                                
                            }
                            if !self.userLoginSwitch.on {
                                self.performSegueWithIdentifier("returnToManageEmp", sender: nil)
                            }
                            
                            if self.userLoginSwitch.on {
                                CloudCode.CreateNewUser(self.userNameTextField.text!, password: pinText.text!, emailAddy: self.emailAddressTextField.text!, adminStatus: self.adminSwitch.on, empID: self.employeeObject.objectId!, completion: { (isComplete, objectID) in
                                    if isComplete {
                                        let user : PFUser!
                                        do {
                                            user = try PFUser.query()!.getObjectWithId(objectID) as! PFUser
                                            self.employeeObject.userPoint = user
                                            self.employeeObject.saveInBackground()
                                        } catch {
                                            
                                        }
                                        let successAlert = UIAlertController(title: "Created", message: "The user has been created, the password is the PIN number for the employee. The employee can reset this by tapping 'Forgot Password' on the main log-in screen", preferredStyle: .Alert)
                                        let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                                            self.performSegueWithIdentifier("returnToManageEmp", sender: nil)
                                        })
                                        successAlert.addAction(okayButton)
                                        self.presentViewController(successAlert, animated: true, completion: nil)
                                    }
                                })
                            }
                        } else {
                            let errorAlert = UIAlertController(title: "PIN", message: "PIN number is in use, please pick a different one", preferredStyle: .Alert)
                            let ok = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                                self.presentViewController(pinAlert, animated: true, completion: nil)
                            })
                            errorAlert.addAction(ok)
                            self.presentViewController(errorAlert, animated: true, completion: nil)
                        }
                    })
                })
                pinAlert.addAction(doneButton)
                self.presentViewController(pinAlert, animated: true, completion: nil)
            }
        }
    }
    
    func verifyPIN(pin : String, completion : (pass : Bool) -> Void) {
        let error = NSErrorPointer()
        let pinQuery = Employee.query()
        pinQuery!.whereKey("active", equalTo: true)
        pinQuery?.whereKey("pinNumber", equalTo: pin)
        let numReturn = pinQuery?.countObjects(error)
        if numReturn == 0 {
            completion(pass: true)
        } else {
            completion(pass: false)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 2 {
            cell.selectionStyle = .None
        }
    }
    
    var newUserObject : PFUser?
    
    @IBAction func userLogInSwitchAction(sender: UISwitch) {
        if sender.on {
            if self.userObject == nil {
                
                if !firstName.text!.isEmpty && !lastName.text!.isEmpty {
                    self.userObject = PFUser()
                    userNameTextField.text = firstName.text!.lowercaseString + lastName.text!.lowercaseString
                }
            }
            usernameLabel.textColor = UIColor.blackColor()
            emailLabel.textColor = UIColor.blackColor()
            messagesEnabledLabel.textColor = UIColor.blackColor()
            adminPrivLabel.textColor = UIColor.blackColor()
            userNameTextField.userInteractionEnabled = true
            emailAddressTextField.userInteractionEnabled = true
            messagesEnabledSwitch.userInteractionEnabled = true
            adminSwitch.userInteractionEnabled = true
            if self.userObject.objectId != nil {
                accessManagerCell.userInteractionEnabled = true
                accessManagerLabel.textColor = UIColor.blackColor()
            }
        } else {
            usernameLabel.textColor = UIColor.lightGrayColor()
            userNameTextField.text = nil
            emailLabel.textColor = UIColor.lightGrayColor()
            emailAddressTextField.text = nil
            messagesEnabledSwitch.setOn(false, animated: true)
            adminSwitch.setOn(false, animated: true)
            adminPrivLabel.textColor = UIColor.lightGrayColor()
            messagesEnabledLabel.textColor = UIColor.lightGrayColor()
            userNameTextField.userInteractionEnabled = false
            emailAddressTextField.userInteractionEnabled = false
            messagesEnabledSwitch.userInteractionEnabled = false
            adminSwitch.userInteractionEnabled = false
            self.accessManagerLabel.textColor = UIColor.lightGrayColor()
            self.accessManagerCell.userInteractionEnabled = false
        }
    }
    
    @IBAction func messagesEnabledSwitchAction(sender: UISwitch) {
        if self.employeeObject.objectId != nil {
            if sender.on {
                self.employeeObject.messages = true
                let provisioningAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .Alert)
                self.presentViewController(provisioningAlert, animated: true, completion: nil)
                self.employeeObject.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                    if (success) {
                        provisioningAlert.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else {
                self.employeeObject.messages = false
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .Alert)
                self.presentViewController(provAlert, animated: true, completion: nil)
                self.employeeObject.saveInBackgroundWithBlock({ (success : Bool, erorr : NSError?) in
                    if (success) {
                        provAlert.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func adminPrivSwitchAction(sender: UISwitch) {
        if self.userObject.objectId != nil {
            if sender.on {
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .Alert)
                self.presentViewController(provAlert, animated: true, completion: nil)
                CloudCode.UpdateUserSpecialAccess(self.userObject.objectId!, specialAccesses: [], completion: { (isComplete) in
                    CloudCode.UpdateUserAdminStatus(self.userObject.username!, adminStatus: true, alert: provAlert, completion: { (complete) in
                        if complete == true {
                            self.updateForAdminStatusChange(true)
                        }
                    })
                })
            } else {
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .Alert)
                self.presentViewController(provAlert, animated: true, completion: nil)
                CloudCode.UpdateUserAdminStatus(self.userObject.username!, adminStatus: false, alert: provAlert, completion: { (complete) in
                    if complete == true {
                        self.updateForAdminStatusChange(false)
                    }
                })
            }
        }
    }
    
    func updateForAdminStatusChange(isAdmin : Bool) {
        if isAdmin {
            accessManagerCell.userInteractionEnabled = false
            accessManagerLabel.textColor = UIColor.lightGrayColor()
        } else {
            accessManagerCell.userInteractionEnabled = true
            accessManagerLabel.textColor = UIColor.blackColor()
        }
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "accessManager" {
            let dest = segue.destinationViewController as! SpecialAccessTableViewController
            dest.userObj = self.userObject
        }
    }
}

extension EmployeeDataTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        let saving = UIAlertController(title: "Updating...", message: nil, preferredStyle: .Alert)
        
        if textField == userNameTextField {
            if self.userObject.objectId != nil {
                self.presentViewController(saving, animated: true, completion: nil)
                CloudCode.UpdateUserInfo(textField.text!.lowercaseString, email: self.userObject.email!, objectId: self.userObject.objectId!, completion: { (isComplete) in
                    if isComplete {
                        saving.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else {
                self.userObject.username = userNameTextField.text?.lowercaseString
            }
            
        }
        
        if textField == emailAddressTextField {
            if GlobalFunctions().isValidEmail(textField.text!) {
                if self.userObject.objectId != nil {
                    self.presentViewController(saving, animated: true, completion: nil)
                    CloudCode.UpdateUserInfo(self.userObject.username!, email: textField.text!.lowercaseString, objectId: self.userObject.objectId!, completion: { (isComplete) in
                        if isComplete {
                            saving.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                } else if self.employeeObject.objectId != nil {
                    print(self.employeeObject.objectId)
                    self.userObject.email = emailAddressTextField.text
                    CloudCode.CreateNewUser(self.userNameTextField.text!, password: "sparkle1", emailAddy: self.emailAddressTextField.text!, adminStatus: adminSwitch.on, empID: self.employeeObject.objectId!, completion: { (isComplete, objectID) in
                        if isComplete {
                            let userCreated = UIAlertController(title: "User Created", message: "The user has been created, the temporary password has been set to 'sparkle1' (without quotes) to update the password have the employee use the forgot password option on the log-in screen", preferredStyle: .Alert)
                            let okay = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                            userCreated.addAction(okay)
                            self.presentViewController(userCreated, animated: true, completion: nil)
                            
                            let userQuery = PFUser.query()
                            userQuery?.whereKey("employee", equalTo: self.employeeObject)
                            userQuery?.getFirstObjectInBackgroundWithBlock({ (user : PFObject?, error : NSError?) in
                                if error == nil {
                                    self.userObject = user as! PFUser
                                    
                                    self.employeeObject.userPoint = self.userObject
                                    self.employeeObject.saveInBackground()
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            })
                        }
                    })
                } else {
                }
            }
        }
        
        if textField == firstName {
            self.employeeObject.firstName = textField.text!
        }
        
        if textField == lastName {
            self.employeeObject.lastName = textField.text!
        }
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == userNameTextField || textField == emailAddressTextField {
            self.tableViewScrollToBottom(true)
        }
        return true
    }
    
    @IBAction func returnFromAM(segue : UIStoryboardSegue) {
        self.userObject.refreshInBackgroundWithBlock { (user : PFObject?, error : NSError?) in
            if error == nil {
                self.userObject = user as! PFUser
            }
        }
    }
    
}






























