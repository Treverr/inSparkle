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
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath != nil {
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
        if employeeObject != nil  {
            firstName.text = employeeObject.firstName
            lastName.text = employeeObject.lastName
            if employeeObject.object(forKey: "roleType") != nil {
                (employeeObject.object(forKey: "roleType")! as AnyObject).fetchInBackground(block: { (daRole : PFObject?, error : Error?) in
                    if error == nil {
                        self.roleLabel.text = daRole!.object(forKey: "roleName") as! String
                        self.roleLabel.textColor = UIColor.black
                    }
                })
            }
            print(employeeObject)
            if employeeObject.userPoint != nil {
                let userID = employeeObject.userPoint!.objectId!
                let query = PFUser.query()
                query?.whereKey("objectId", equalTo: userID)
                query?.getFirstObjectInBackground(block: { (userData : PFObject?, error : Error?) in
                    let userInfo = userData as! PFUser
                    self.userObject = userInfo
                    self.userLoginSwitch.setOn(true, animated: false)
                    self.userNameTextField.text = userInfo.username
                    self.emailAddressTextField.text = userInfo.email
                    print(userInfo)
                    if self.employeeObject.userPoint!.object(forKey: "isAdmin") as! Bool {
                        self.adminSwitch.setOn(true, animated: false)
                        self.accessManagerLabel.textColor = UIColor.lightGray
                        self.accessManagerCell.isUserInteractionEnabled = false
                    } else {
                        
                    }
                    if self.employeeObject.messages {
                        self.messagesEnabledSwitch.setOn(true, animated: false)
                    }
                })
                
            } else {
                userLoginSwitch.setOn(false, animated: false)
                usernameLabel.textColor = UIColor.lightGray
                emailLabel.textColor = UIColor.lightGray
                adminPrivLabel.textColor = UIColor.lightGray
                messagesEnabledLabel.textColor = UIColor.lightGray
                userNameTextField.isUserInteractionEnabled = false
                emailAddressTextField.isUserInteractionEnabled = false
                messagesEnabledSwitch.isUserInteractionEnabled = false
                adminSwitch.isUserInteractionEnabled = false
                self.accessManagerLabel.textColor = UIColor.lightGray
                self.accessManagerCell.isUserInteractionEnabled = false
                
            }
            if employeeObject.active {
                disableEnableEmployee.setTitle("Disable Employee", for: UIControlState())
            } else {
                disableEnableEmployee.setTitle("Enable Employee", for: UIControlState())
                disableEnableEmployee.setTitleColor(UIColor.blue, for: UIControlState())
            }
        } else {
            self.employeeObject = Employee()
            usernameLabel.textColor = UIColor.lightGray
            userNameTextField.isUserInteractionEnabled = false
            emailLabel.textColor = UIColor.lightGray
            emailAddressTextField.isUserInteractionEnabled = false
            messagesEnabledLabel.textColor = UIColor.lightGray
            messagesEnabledSwitch.isUserInteractionEnabled = false
            adminSwitch.isUserInteractionEnabled = false
            adminPrivLabel.textColor = UIColor.lightGray
            accessManagerCell.isUserInteractionEnabled = false
            accessManagerLabel.textColor = UIColor.lightGray
            disableEnableEmployee.setTitle("Save", for: UIControlState())
            disableEnableEmployee.setTitleColor(UIColor.blue, for: UIControlState())
        }
    }
    
    func getRoles() {
        let query = Role.query()
        query?.findObjectsInBackground(block: { (theRoles : [PFObject]?, error : Error?) in
            if error == nil {
                for role in theRoles! {
                    let roleObj = role as! Role
                    self.roleDict[roleObj.roleName] = roleObj
                }
                self.setupRoleDropDown()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
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
        roleDropDown.direction = .any
        roleDropDown.anchorView = self.roleCell
        roleDropDown.dismissMode = .automatic
        
        roleDropDown.selectionAction = { [unowned self] (index, item) in
            self.roleLabel.text = item
            self.roleLabel.textColor = UIColor.black
            self.selectedRole = self.roleDict[item]
            print(self.selectedRole)
            self.employeeObject.roleType = self.selectedRole
            self.employeeObject.saveInBackground()
        }
    }
    
    
    @IBAction func disableEnableEmployeeAction(_ sender: AnyObject) {
        if disableEnableEmployee.titleLabel?.text == "Disable Employee" {
            let disableAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to disable the employee?", preferredStyle: .alert)
            let confirmButton = UIAlertAction(title: "Confirm", style: .destructive, handler: { (action) in
                var userID : String!
                let userQuery = PFUser.query()
                userQuery?.whereKey("employee", equalTo: self.employeeObject)
                userQuery?.findObjectsInBackground(block: { (userFound : [PFObject]?, error : Error?) in
                    if error == nil {
                        if userFound?.count == 1 {
                            userID = userFound?.first?.objectId
                            CloudCode.DisableEnableUser(userID, enabled: false, completion: { (complete) in
                                if complete {
                                    
                                }
                            })
                        }
                    }
                })
                self.employeeObject?.remove(forKey: "pinNumber")
                self.employeeObject?.active = false
                self.employeeObject.saveInBackground(block: { (success : Bool, error : Error?) in
                    if success {
                        self.performSegue(withIdentifier: "returnToManageEmp", sender: nil)
                    }
                })
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            disableAlert.addAction(cancelButton)
            disableAlert.addAction(confirmButton)
            self.present(disableAlert, animated: true, completion: nil)
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
                //                let errorAlert = UIAlertController(title: "Check Fields", message: missingFields + " Are missing information. Please check and try again.", preferredStyle: .Alert)
            } else {
                var pinText : UITextField!
                let pinAlert = UIAlertController(title: "PIN Selection", message: "Select a 4-digit PIN", preferredStyle: .alert)
                pinAlert.addTextField(configurationHandler: { (textField) in
                    pinText = textField
                })
                
                let doneButton = UIAlertAction(title: "Done", style: .default, handler: { (action) in
                    self.verifyPIN(pinText.text!, completion: { (pass) in
                        if pass {
                            if self.employeeObject.objectId == nil {
                                //                                let name = self.firstName.text! + " " + self.lastName.text!
                                //                                let email = self.emailAddressTextField.text!
                                //                                CloudCode.SendWelcomeEmail(name, toEmail: email, emailAddress: email)
                            }
                            self.employeeObject.firstName = self.firstName.text!.capitalized
                            self.employeeObject.lastName = self.lastName.text!.capitalized
                            self.employeeObject.messages = self.messagesEnabledSwitch.isOn
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
                            if !self.userLoginSwitch.isOn {
                                self.performSegue(withIdentifier: "returnToManageEmp", sender: nil)
                            }
                            
                            if self.userLoginSwitch.isOn {
                                if self.employeeObject.userPoint == nil {
                                    CloudCode.CreateNewUser(self.userNameTextField.text!, password: pinText.text!, emailAddy: self.emailAddressTextField.text!, adminStatus: self.adminSwitch.isOn, empID: self.employeeObject.objectId!, completion: { (isComplete, objectID) in
                                        if isComplete {
                                            let user : PFUser!
                                            do {
                                                user = try PFUser.query()!.getObjectWithId(objectID) as! PFUser
                                                self.employeeObject.userPoint = user
                                                self.employeeObject.saveInBackground()
                                            } catch {
                                                
                                            }
                                            let successAlert = UIAlertController(title: "Created", message: "The user has been created, the password is the PIN number for the employee. The employee can reset this by tapping 'Forgot Password' on the main log-in screen", preferredStyle: .alert)
                                            let okayButton = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                                self.performSegue(withIdentifier: "returnToManageEmp", sender: nil)
                                            })
                                            successAlert.addAction(okayButton)
                                            self.present(successAlert, animated: true, completion: nil)
                                        }
                                    })
                                } else {
                                    CloudCode.DisableEnableUser(self.employeeObject.userPoint!.objectId!, enabled: true, completion: { (complete) in
                                        if complete {
                                            let enabledUser = UIAlertController(title: "Enabled", message: "The user has been restored, if the employee does not remember the password they can reset it on the log-in screen", preferredStyle: .alert)
                                            let okay = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                                self.performSegue(withIdentifier: "returnToManageEmp", sender: nil)
                                            })
                                            enabledUser.addAction(okay)
                                            self.present(enabledUser, animated: true, completion: nil)
                                        }
                                    })
                                }
                            }
                        } else {
                            let errorAlert = UIAlertController(title: "PIN", message: "PIN number is in use, please pick a different one", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                self.present(pinAlert, animated: true, completion: nil)
                            })
                            errorAlert.addAction(ok)
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                    })
                })
                pinAlert.addAction(doneButton)
                self.present(pinAlert, animated: true, completion: nil)
            }
        }
    }
    
    func verifyPIN(_ pin : String, completion : (_ pass : Bool) -> Void) {
        let error: ErrorPointer = nil
        let pinQuery = Employee.query()
        pinQuery!.whereKey("active", equalTo: true)
        pinQuery?.whereKey("pinNumber", equalTo: pin)
        let numReturn = pinQuery?.countObjects(error)
        if numReturn == 0 {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section != 2 {
            cell.selectionStyle = .none
        }
    }
    
    var newUserObject : PFUser?
    
    @IBAction func userLogInSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            if self.userObject == nil {
                
                if !firstName.text!.isEmpty && !lastName.text!.isEmpty {
                    self.userObject = PFUser()
                    userNameTextField.text = firstName.text!.lowercased() + lastName.text!.lowercased()
                }
            }
            usernameLabel.textColor = UIColor.black
            emailLabel.textColor = UIColor.black
            messagesEnabledLabel.textColor = UIColor.black
            adminPrivLabel.textColor = UIColor.black
            userNameTextField.isUserInteractionEnabled = true
            emailAddressTextField.isUserInteractionEnabled = true
            messagesEnabledSwitch.isUserInteractionEnabled = true
            adminSwitch.isUserInteractionEnabled = true
            if self.userObject.objectId != nil {
                accessManagerCell.isUserInteractionEnabled = true
                accessManagerLabel.textColor = UIColor.black
            }
        } else {
            usernameLabel.textColor = UIColor.lightGray
            userNameTextField.text = nil
            emailLabel.textColor = UIColor.lightGray
            emailAddressTextField.text = nil
            messagesEnabledSwitch.setOn(false, animated: true)
            adminSwitch.setOn(false, animated: true)
            adminPrivLabel.textColor = UIColor.lightGray
            messagesEnabledLabel.textColor = UIColor.lightGray
            userNameTextField.isUserInteractionEnabled = false
            emailAddressTextField.isUserInteractionEnabled = false
            messagesEnabledSwitch.isUserInteractionEnabled = false
            adminSwitch.isUserInteractionEnabled = false
            self.accessManagerLabel.textColor = UIColor.lightGray
            self.accessManagerCell.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func messagesEnabledSwitchAction(_ sender: UISwitch) {
        if self.employeeObject.objectId != nil {
            if sender.isOn {
                self.employeeObject.messages = true
                let provisioningAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .alert)
                self.present(provisioningAlert, animated: true, completion: nil)
                self.employeeObject.saveInBackground(block: { (success : Bool, error : Error?) in
                    if (success) {
                        provisioningAlert.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                self.employeeObject.messages = false
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .alert)
                self.present(provAlert, animated: true, completion: nil)
                self.employeeObject.saveInBackground(block: { (success : Bool, erorr : Error?) in
                    if (success) {
                        provAlert.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func adminPrivSwitchAction(_ sender: UISwitch) {
        if self.userObject.objectId != nil {
            if sender.isOn {
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .alert)
                self.present(provAlert, animated: true, completion: nil)
                CloudCode.UpdateUserSpecialAccess(self.userObject.objectId!, specialAccesses: [], completion: { (isComplete) in
                    CloudCode.UpdateUserAdminStatus(self.userObject.username!, adminStatus: true, alert: provAlert, completion: { (complete) in
                        if complete == true {
                            self.updateForAdminStatusChange(true)
                        }
                    })
                })
            } else {
                let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .alert)
                self.present(provAlert, animated: true, completion: nil)
                CloudCode.UpdateUserAdminStatus(self.userObject.username!, adminStatus: false, alert: provAlert, completion: { (complete) in
                    if complete == true {
                        self.updateForAdminStatusChange(false)
                    }
                })
            }
        }
    }
    
    func updateForAdminStatusChange(_ isAdmin : Bool) {
        if isAdmin {
            accessManagerCell.isUserInteractionEnabled = false
            accessManagerLabel.textColor = UIColor.lightGray
        } else {
            accessManagerCell.isUserInteractionEnabled = true
            accessManagerLabel.textColor = UIColor.black
        }
    }
    
    func tableViewScrollToBottom(_ animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accessManager" {
            let dest = segue.destination as! SpecialAccessTableViewController
            dest.userObj = self.userObject
        }
    }
}

extension EmployeeDataTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let saving = UIAlertController(title: "Updating...", message: nil, preferredStyle: .alert)
        
        if textField == userNameTextField {
            if self.userObject.objectId != nil {
                self.present(saving, animated: true, completion: nil)
                print(textField.text?.lowercased(), self.userObject.email!, self.userObject.objectId!)
                CloudCode.UpdateUserInfo(textField.text!.lowercased(), email: self.userObject.email!, objectId: self.userObject.objectId!, completion: { (isComplete) in
                    if isComplete {
                        saving.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                self.userObject.username = userNameTextField.text?.lowercased()
            }
            
        }
        
        if textField == emailAddressTextField {
            if GlobalFunctions().isValidEmail(textField.text!) {
                if self.userObject.objectId != nil {
                    self.present(saving, animated: true, completion: nil)
                    CloudCode.UpdateUserInfo(self.userObject.username!, email: textField.text!.lowercased(), objectId: self.userObject.objectId!, completion: { (isComplete) in
                        if isComplete {
                            saving.dismiss(animated: true, completion: nil)
                        }
                    })
                } else if self.employeeObject.objectId != nil {
                    print(self.employeeObject.objectId)
                    self.userObject.email = emailAddressTextField.text
                    CloudCode.CreateNewUser(self.userNameTextField.text!, password: "sparkle1", emailAddy: self.emailAddressTextField.text!, adminStatus: adminSwitch.isOn, empID: self.employeeObject.objectId!, completion: { (isComplete, objectID) in
                        if isComplete {
                            let userCreated = UIAlertController(title: "User Created", message: "The user has been created, the temporary password has been set to 'sparkle1' (without quotes) to update the password have the employee use the forgot password option on the log-in screen", preferredStyle: .alert)
                            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            userCreated.addAction(okay)
                            self.present(userCreated, animated: true, completion: nil)
                            
                            let userQuery = PFUser.query()
                            userQuery?.whereKey("employee", equalTo: self.employeeObject)
                            userQuery?.getFirstObjectInBackground(block: { (user : PFObject?, error : Error?) in
                                if error == nil {
                                    self.userObject = user as! PFUser
                                    
                                    self.employeeObject.userPoint = self.userObject
                                    self.employeeObject.saveInBackground()
                                    self.dismiss(animated: true, completion: nil)
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == userNameTextField || textField == emailAddressTextField {
            self.tableViewScrollToBottom(true)
        }
        return true
    }
    
    @IBAction func returnFromAM(_ segue : UIStoryboardSegue) {
        self.userObject.fetchInBackground { (user : PFObject?, error : Error?) in
            if error == nil {
                self.userObject = user as! PFUser
            }
        }
    }
    
}
