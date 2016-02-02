//
//  ComposeMessageTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/27/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import GooglePlacesAutocomplete
import PhoneNumberKit

class ComposeMessageTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    
    var isNewMessage : Bool = true
    var existingMessage : Messages?
    
    @IBOutlet var dateTimeOfMessage: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var altPhoneTextField: UITextField!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var signedLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var statusLabel: UILabel!
    
    var selectedEmployee : Employee?
    var formatter = NSDateFormatter()
    
    override func viewWillAppear(animated: Bool) {
        
        if isNewMessage {
            let employeeData = PFUser.currentUser()?.objectForKey("employee") as! Employee
            print(employeeData)
            employeeData.fetchIfNeededInBackgroundWithBlock { (employee : PFObject?, error : NSError?) -> Void in
                if error == nil {
                    self.signedLabel.text = "Signed: " + employeeData.firstName + " " + employeeData.lastName
                }
            }
        } else {
            if MessagesDataObjects.selectedEmp != nil {
                selectedEmployee = MessagesDataObjects.selectedEmp
            }
            if existingMessage != nil {
                existingMessage!.status = "Read"
                existingMessage!.statusTime = NSDate()
                existingMessage!.unread = false
                existingMessage!.saveInBackground()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFields", name: "UpdateFieldsOnNewMessage", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAddressLabel", name: "UpdateComposeMessageLabel", object: nil)
        
        addressTextField.userInteractionEnabled = true
        addressTextField.addTarget(self, action: Selector("googlePlacesAPI"), forControlEvents: UIControlEvents.EditingDidBegin)
        
        phoneTextField.delegate = self
        altPhoneTextField.delegate = self
        
    }
    
    func updateSignedEmployee() {
        var signed : PFUser?
        existingMessage?.signed.fetchInBackgroundWithBlock({ (user : PFObject?, error :NSError?) -> Void in
            if error == nil {
                signed = user as! PFUser
                print(self.existingMessage?.signed)
                let signedEmployee = self.existingMessage?.signed.objectForKey("employee") as! Employee
                signedEmployee.fetchInBackgroundWithBlock({ (signedEmployee : PFObject?, error : NSError?) in
                    if error == nil && signedEmployee != nil {
                        let signed = signedEmployee as! Employee
                        self.signedLabel.text = "Signed: " + signed.firstName + " " + signed.lastName
                    }
                })
            }
        })
        
    }
    
    func updateMessageDetails() {
        let name = existingMessage!.messageFromName
        let address = existingMessage!.messageFromAddress
        let phone = existingMessage!.messageFromPhone
        let altPhone = existingMessage?.altPhone
        let email = existingMessage?.emailAddy
        let message = existingMessage!.theMessage
        let status = existingMessage?.status
        
        nameTextField.text = name
        addressTextField.text = address
        phoneTextField.text = phone
        
        if altPhone != nil {
            altPhoneTextField.text = altPhone!
        }
        
        if email != nil {
            emailAddress.text = email!
        }
        
        messageTextView.text = message
        statusLabel.text = "Status: " + status!
        
    }
    
    func getRecip() {
        self.addImage.hidden = true
        let recip = existingMessage?.recipient
        recip?.fetchInBackgroundWithBlock({ (recipient : PFObject?, error : NSError?) in
            if error == nil {
                let theRecip = recipient as! Employee
                
                self.recipientLabel.text = "To: " + theRecip.firstName + " " + theRecip.lastName
                MessagesDataObjects.selectedEmp = theRecip
                print(self.selectedEmployee)
                
            }
        })
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        var phoneNumber : PhoneNumber?
        if textField == phoneTextField {
            do {
                phoneNumber = try PhoneNumber(rawNumber: phoneTextField.text!)
            } catch { }
            phoneTextField.text = phoneNumber?.toNational()
        }
        
        if textField == altPhoneTextField {
            do {
                phoneNumber = try PhoneNumber(rawNumber: altPhoneTextField.text!)
            } catch { }
            altPhoneTextField.text = phoneNumber?.toNational()
        }
        
        return true
    }
    
    func googlePlacesAPI() {
        
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyCFBaUShWIatpRNiDtc8IcE8reNMs0kM7I",
            placeType: .Address
        )
        
        gpaViewController.placeDelegate = self
        gpaViewController.locationBias = LocationBias(latitude: 39.4931008, longitude: -87.3789913, radius: 120)
        gpaViewController.navigationBar.barStyle = UIBarStyle.Black
        gpaViewController.navigationBar.barTintColor = Colors.sparkleBlue
        gpaViewController.navigationBar.tintColor = UIColor.whiteColor()
        
        presentViewController(gpaViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recipientLabel.text = "Add Recipient"
        
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        if isNewMessage {
            dateTimeOfMessage.text! = formatter.stringFromDate(NSDate())
        } else {
            dateTimeOfMessage.text! = formatter.stringFromDate(existingMessage!.dateTimeMessage)
        }
        
        
        self.tabBarController?.tabBar.hidden = true
        
        if isNewMessage == false {
            getRecip()
            updateMessageDetails()
            updateSignedEmployee()
            self.navigationItem.title = "Message"
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isNewMessage == true && indexPath.section == 1 && indexPath.row == 0 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }
    
    
    @IBAction func saveButton(sender: AnyObject) {
        selectedEmployee = MessagesDataObjects.selectedEmp
        
        if (isNewMessage) {
            let messObj = Messages()
            messObj.dateTimeMessage = NSDate()
            messObj.recipient = selectedEmployee!
            messObj.messageFromName = nameTextField.text!
            messObj.messageFromPhone = phoneTextField.text!
            if (addressTextField.text?.isEmpty) == false {
                messObj.messageFromAddress = addressTextField.text!
            }
            messObj.theMessage = messageTextView.text!
            messObj.signed = PFUser.currentUser()!
            messObj.unread = true
            messObj.dateEntered = NSDate()
            messObj.status = "Unread"
            messObj.statusTime = NSDate()
            if !altPhoneTextField.text!.isEmpty {
                messObj.altPhone = altPhoneTextField.text!
            }
            if !emailAddress.text!.isEmpty {
                messObj.emailAddy = emailAddress.text!
            }
            messObj.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                if error == nil && success == true {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessagesTableViewController", object: nil)
                    self.performSegueWithIdentifier("unwindToMessages", sender: self)
                    PushNotifications.messagesPushNotification(self.selectedEmployee!)
                    MessagesDataObjects.selectedEmp = nil
                    }
                }
            })
        } else {
            let messObj = existingMessage!
            let sepStatus = statusLabel.text?.componentsSeparatedByString(": ")
            let status = sepStatus![1]
            
            messObj.recipient = selectedEmployee!
            messObj.messageFromName = nameTextField.text!
            messObj.messageFromPhone = phoneTextField.text!
            if (addressTextField.text?.isEmpty) == false {
                messObj.messageFromAddress = addressTextField.text!
            }
            messObj.theMessage = messageTextView.text!
            if messObj.status != status {
                messObj.statusTime = NSDate()
            }
            messObj.status = status
            if status == "Unread" {
                messObj.unread = true
            } else {
                messObj.unread = false
            }
            print(messObj.status)
            
            if !altPhoneTextField.text!.isEmpty {
                messObj.altPhone = altPhoneTextField.text!
            }
            if !emailAddress.text!.isEmpty {
                messObj.emailAddy = emailAddress.text!
            }
            messObj.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                if error == nil && success == true {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessagesTableViewController", object: nil)
                        self.performSegueWithIdentifier("unwindToMessages", sender: self)
                        PushNotifications.messagesPushNotification(self.selectedEmployee!)
                        MessagesDataObjects.selectedEmp = nil
                    }
                }
            })
        }
        
        
    }
    
    @IBOutlet weak var addRecipCell: UITableViewCell!
    
    @IBAction func returnFromEmployeeSelection(segue : UIStoryboardSegue) {
        let recipName = selectedEmployee!.firstName + " " + selectedEmployee!.lastName
        recipientLabel.text = "To: " + recipName
        addImage.hidden = true
        
        recipientLabel.bounds = addRecipCell.frame
        recipientLabel.textAlignment = .Center
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            popover("Messages", vcID: "EmpPopover", sender: tableView.cellForRowAtIndexPath(indexPath)!)
        }
    }
    
    func popover (sb : String, vcID : String, sender : UITableViewCell) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(vcID)
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func updateFields() {
        
        let selectCx = CustomerLookupObjects.slectedCustomer
        print(selectCx)
        nameTextField.text = selectCx!.firstName!.capitalizedString + " " + selectCx!.lastName!.capitalizedString
        phoneTextField.text = selectCx!.phoneNumber
        addressTextField.text = "\(selectCx!.addressStreet.capitalizedString) \(selectCx!.addressCity.capitalizedString), \(selectCx!.addressState) \(selectCx!.ZIP)"
        selectedEmployee = MessagesDataObjects.selectedEmp
    }
    
    func updateAddressLabel() {
        addressTextField.text = GoogleAddress.address
        GoogleAddress.address = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CustomerLookup" {
            CustomerLookupObjects.fromVC = "NewMessage"
        }
        
        if segue.identifier == "ViewEditMessage" {
            
        }
        
        if segue.identifier == "NotesSegue" {
            let destinationVC = segue.destinationViewController as! MessageNotesTableViewController
            if existingMessage != nil {
                destinationVC.linkingMessage = existingMessage
            }
        }
    }
    
    @IBAction func updateStatusLabel(segue : UIStoryboardSegue) {
        
    }
    
    
}

extension ComposeMessageTableViewController : GooglePlacesAutocompleteDelegate {
    
    func placeSelected(place: Place) {
        let houseNumbers = place.desc.componentsSeparatedByString(" ")[0]
        place.getDetails({ (thePlaceDetails) -> () in
            let fullAddress = thePlaceDetails.fullAddress.componentsSeparatedByString(" ")[0]
            if self.isNumeric(fullAddress) {
                print(place.desc)
                GoogleAddress.address = thePlaceDetails.fullAddress
            } else {
                GoogleAddress.address = houseNumbers + " " + thePlaceDetails.fullAddress
            }
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateComposeMessageLabel", object: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    func isNumeric(a: String) -> Bool {
        return Int(a) != nil
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
