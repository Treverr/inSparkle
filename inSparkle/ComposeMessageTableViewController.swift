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
    var isSent : Bool = false
    
    @IBOutlet var dateTimeOfMessage: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var altPhoneTextField: UITextField!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var signedLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var phoneCallButton: UIButton!
    @IBOutlet var altPhoneCallButton: UIButton!
    @IBOutlet weak var notesLabel: UILabel!
    
    var selectedEmployee : Employee?
    var formatter = DateFormatter()
    
    var QuckActionsVC : QuickActionsMasterViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if StaticViews.masterView != nil {
                    self.QuckActionsVC = StaticViews.masterView.childViewControllers.first?.childViewControllers.first as! QuickActionsMasterViewController
        }
        
        if isNewMessage {
            let employeeData = PFUser.current()?.object(forKey: "employee") as! Employee
            print(employeeData)
            employeeData.fetchIfNeededInBackground { (employee : PFObject?, error : Error?) -> Void in
                if error == nil {
                    self.signedLabel.text = "Signed: " + employeeData.firstName + " " + employeeData.lastName
                }
            }
            
            if self.selectedEmployee != nil {
                let recipName = selectedEmployee!.firstName + " " + selectedEmployee!.lastName
                recipientLabel.text = "To: " + recipName
                
                recipientLabel.bounds = addRecipCell.frame
                recipientLabel.textAlignment = .center
    
            }
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(ComposeMessageTableViewController.close)
            )
        } else {
            if MessagesDataObjects.selectedEmp != nil {
                selectedEmployee = MessagesDataObjects.selectedEmp
            }
            
            if existingMessage != nil && isSent == false && existingMessage?.unread == true {
                existingMessage!.status = "Read"
                existingMessage!.statusTime = Date()
                existingMessage!.unread = false
                existingMessage!.saveInBackground()
            }
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageTableViewController.updateFields), name: NSNotification.Name(rawValue: "UpdateFieldsOnNewMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageTableViewController.updateAddressLabel), name: NSNotification.Name(rawValue: "UpdateComposeMessageLabel"), object: nil)
        
        addressTextField.isUserInteractionEnabled = true
        addressTextField.addTarget(self, action: #selector(ComposeMessageTableViewController.googlePlacesAPI), for: UIControlEvents.editingDidBegin)
        
        phoneTextField.delegate = self
        altPhoneTextField.delegate = self
        messageTextView.delegate = self
        nameTextField.delegate = self
        addressTextField.delegate = self
        emailAddress.delegate = self
        messageTextView.delegate = self
        
        if !nameTextField.text!.isEmpty && !phoneTextField.text!.isEmpty {
            enableDisableSaveButton(true)
        } else {
            enableDisableSaveButton(false)
        }
        
        self.getNotesNumber()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeMessageTableViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    var activeField : UIView!
    
    func keyboardWillShow(_ notification : Notification) {
        let info = (notification as NSNotification).userInfo!
        let kbSize : CGSize = (info[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        var contentInsets : UIEdgeInsets!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height - 200, 0)
        } else {
            contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height - 50, 0)
        }
        
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        
        if messageTextView.isFirstResponder {
            let indexToScrollTo = IndexPath(row: 7, section: 1)
            self.tableView.scrollToRow(at: indexToScrollTo, at: .bottom, animated: true)
        }
    }
    
    func getNotesNumber() {
        if existingMessage != nil && isNewMessage == false {
            let query = MessageNotes.query()!
            query.whereKey("pointerMessage", equalTo: existingMessage!)
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (notes : [PFObject]?, error : Error?) in
                if error == nil {
                    if notes!.count > 0 {
                        self.notesLabel.text = "Notes " + "(\(notes!.count))"
                    }
                }
            })
        }
    }
    
    func keyboardWillHide(_ notification : Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
    }
    
    
    func updateSignedEmployee() {
        var signed : PFUser?
        existingMessage?.signed.fetchInBackground(block: { (user : PFObject?, error :Error?) -> Void in
            if error == nil {
                signed = user as! PFUser
                print(self.existingMessage?.signed)
                let signedEmployee = self.existingMessage?.signed.object(forKey: "employee") as! Employee
                signedEmployee.fetchInBackground(block: { (signedEmployee : PFObject?, error : Error?) in
                    if error == nil && signedEmployee != nil {
                        let signed = signedEmployee as! Employee
                        self.signedLabel.text = "Signed: " + signed.firstName + " " + signed.lastName
                    }
                })
            }
        })
        
    }
    
    
    
    func enableDisableSaveButton(_ enabled : Bool) {
        saveButton.isEnabled = enabled
        if enabled {
            saveButton.tintColor = UIColor.white
        } else {
            saveButton.tintColor = UIColor.lightGray
        }
    }
    
    func updateMessageDetails() {
        let name = existingMessage!.messageFromName
        let phone = existingMessage!.messageFromPhone
        let altPhone = existingMessage?.altPhone
        let email = existingMessage?.emailAddy
        let message = existingMessage!.theMessage
        let status = existingMessage?.status
        
        nameTextField.text = name
        
        if existingMessage?.messageFromAddress != nil {
            addressTextField.text! = existingMessage!.messageFromAddress!
        }
        
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
        let recip = existingMessage?.recipient
        recip?.fetchInBackground(block: { (recipient : PFObject?, error : Error?) in
            if error == nil {
                let theRecip = recipient as! Employee
                
                self.recipientLabel.text = "To: " + theRecip.firstName + " " + theRecip.lastName
                MessagesDataObjects.selectedEmp = theRecip
                
            }
        })
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var phoneNumber : PhoneNumber?
        if textField == phoneTextField {
            do {
                phoneNumber = try PhoneNumberKit().parse(phoneTextField.text!)
                phoneTextField.text = PhoneNumberKit().format(phoneNumber!, toType: .national)
            } catch {
                print(error)
            }
            
        }
        
        if textField == altPhoneTextField {
            do {
                phoneNumber = try PhoneNumberKit().parse(altPhoneTextField.text!)
                altPhoneTextField.text = PhoneNumberKit().format(phoneNumber!, toType: .national)
            } catch {
            }
            
        }
        
        return true
    }
    
    func googlePlacesAPI() {
        
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyCFBaUShWIatpRNiDtc8IcE8reNMs0kM7I",
            placeType: .address
        )
        
        gpaViewController.placeDelegate = self
        gpaViewController.locationBias = LocationBias(latitude: 39.4931008, longitude: -87.3789913, radius: 120)
        gpaViewController.navigationBar.barStyle = UIBarStyle.black
        gpaViewController.navigationBar.barTintColor = Colors.sparkleBlue
        gpaViewController.navigationBar.tintColor = UIColor.white
    
        present(gpaViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recipientLabel.text = "Add Recipient"
        
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        if isNewMessage {
            dateTimeOfMessage.text! = formatter.string(from: Date())
        } else {
            dateTimeOfMessage.text! = formatter.string(from: existingMessage!.dateTimeMessage as Date)
        }
        
        if isNewMessage == false {
            getRecip()
            updateMessageDetails()
            updateSignedEmployee()
            self.navigationItem.title = "Message"
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        if StaticViews.masterView != nil {
                    self.QuckActionsVC.shouldShowHideMaster(true)
        }

        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isNewMessage == true && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            return 0
        }
        
        if isNewMessage == true && (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBAction func saveButton(_ sender: AnyObject) {
        selectedEmployee = MessagesDataObjects.selectedEmp
        
        saveButton.tintColor = UIColor.gray
        saveButton.isEnabled = false
        
        if (isNewMessage) {
            
            if self.recipientLabel.text == "Add Recipient" {
                let recipAlert = UIAlertController(title: "Add a Recipient", message: "Please select a recipient to send the message to", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                recipAlert.addAction(okayButton)
                self.present(recipAlert, animated: true, completion: nil)
                
                saveButton.tintColor = UIColor.white
                saveButton.isEnabled = true
                
                return
            }
            
            let messObj = Messages()
            messObj.dateTimeMessage = Date()
            messObj.recipient = selectedEmployee!
            messObj.messageFromName = nameTextField.text!
            messObj.messageFromPhone = phoneTextField.text!
            if (addressTextField.text?.isEmpty) == false {
                messObj.messageFromAddress = addressTextField.text!
            }
            messObj.theMessage = messageTextView.text!
            messObj.signed = PFUser.current()!
            messObj.unread = true
            messObj.dateEntered = Date()
            messObj.status = "Unread"
            messObj.statusTime = Date()
            if !altPhoneTextField.text!.isEmpty {
                messObj.altPhone = altPhoneTextField.text!
            }
            if !emailAddress.text!.isEmpty {
                messObj.emailAddy = emailAddress.text!
            }
            messObj.saveInBackground(block: { (success : Bool, error : Error?) -> Void in
                if error == nil && success == true {
                    let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        //                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessagesTableViewController", object: nil)
                        self.performSegue(withIdentifier: "unwindToMessages", sender: self)
                        PushNotifications.messagesPushNotification(self.selectedEmployee!)
                        MessagesDataObjects.selectedEmp = nil
                    }
                }
                if error != nil {
                    self.saveButton.tintColor = UIColor.blue
                    self.saveButton.isEnabled = true
                    let alert = UIAlertController()
                    switch error!._code {
                    case 100:
                        alert.title = "Error"
                        alert.message = "Check network connection and try again"
                        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alert.addAction(okayButton)
                    default: break
                    }
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            let messObj = existingMessage!
            let sepStatus = statusLabel.text?.components(separatedBy: ": ")
            let status = sepStatus![1]
            
            messObj.recipient = selectedEmployee!
            messObj.messageFromName = nameTextField.text!
            messObj.messageFromPhone = phoneTextField.text!
            if (addressTextField.text?.isEmpty) == false {
                messObj.messageFromAddress = addressTextField.text!
            }
            messObj.theMessage = messageTextView.text!
            if messObj.status != status {
                messObj.statusTime = Date()
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
            messObj.saveInBackground(block: { (success : Bool, error : Error?) -> Void in
                if error == nil && success == true {
                    let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        //                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessagesTableViewController", object: nil)
                        self.performSegue(withIdentifier: "unwindToMessages", sender: self)
                        if self.isNewMessage == true {
                            PushNotifications.messagesPushNotification(self.selectedEmployee!)
                        }
                        MessagesDataObjects.selectedEmp = nil
                    }
                }
            })
        }
        
        
    }
    
    @IBOutlet weak var addRecipCell: UITableViewCell!
    
    @IBAction func returnFromEmployeeSelection(_ segue : UIStoryboardSegue) {
        let recipName = selectedEmployee!.firstName + " " + selectedEmployee!.lastName
        recipientLabel.text = "To: " + recipName
        
        recipientLabel.bounds = addRecipCell.frame
        recipientLabel.textAlignment = .center
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            popover("Messages", vcID: "EmpPopover", sender: tableView.cellForRow(at: indexPath)!)
        }
    }
    
    func popover (_ sb : String, vcID : String, sender : UITableViewCell) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: vcID)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        present(vc, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func updateFields() {
        
        let selectCx = CustomerLookupObjects.slectedCustomer
        print(selectCx)
        nameTextField.text = selectCx!.firstName!.capitalized + " " + selectCx!.lastName!.capitalized
        phoneTextField.text = selectCx!.phoneNumber
        addressTextField.text = "\(selectCx!.addressStreet.capitalized) \(selectCx!.addressCity.capitalized), \(selectCx!.addressState) \(selectCx!.ZIP)"
        selectedEmployee = MessagesDataObjects.selectedEmp
    }
    
    func updateAddressLabel() {
        addressTextField.text = GoogleAddress.address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CustomerLookup" {
            CustomerLookupObjects.fromVC = "NewMessage"
        }
        
        if segue.identifier == "ViewEditMessage" {
            
        }
        
        if segue.identifier == "NotesSegue" {
            let destinationVC = segue.destination as! MessageNotesTableViewController
            if existingMessage != nil {
                destinationVC.linkingMessage = existingMessage
            }
        }
    }
    
    @IBAction func updateStatusLabel(_ segue : UIStoryboardSegue) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField || textField == phoneTextField {
            if !nameTextField.text!.isEmpty && !phoneTextField.text!.isEmpty {
                enableDisableSaveButton(true)
            } else {
                enableDisableSaveButton(false)
            }
        }
    }
    
    @IBAction func phoneCallButtonAction(_ sender: AnyObject) {
        var phoneNumber : String! = String(phoneTextField.text!)
        do {
            let phone = try PhoneNumberKit().parse(phoneNumber)
            phoneNumber = phone.numberString
            
            let confirmCall = UIAlertController(title: phoneNumber, message: nil, preferredStyle: .alert)
            let callButton = UIAlertAction(title: "Call", style: .default, handler: { (action) in
                GlobalFunctions().callNumber(phoneNumber)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            confirmCall.addAction(cancelButton)
            confirmCall.addAction(callButton)
            self.present(confirmCall, animated: true, completion: nil)
            
        } catch {
            
        }
    }
    
    @IBAction func altPhoneCallButtonAction(_ sender: AnyObject) {
        var phoneNumber : String! = String(altPhoneTextField.text!)
        do {
            let phone = try PhoneNumberKit().parse(phoneNumber)
            phoneNumber = phone.numberString
            
            let confirmCall = UIAlertController(title: phoneNumber, message: nil, preferredStyle: .alert)
            let callButton = UIAlertAction(title: "Call", style: .default, handler: { (action) in
                GlobalFunctions().callNumber(phoneNumber)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            confirmCall.addAction(cancelButton)
            confirmCall.addAction(callButton)
            self.present(confirmCall, animated: true, completion: nil)
            
        } catch {
            
        }
        
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ComposeMessageTableViewController : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        
        return true
    }

    
}

extension ComposeMessageTableViewController : GooglePlacesAutocompleteDelegate {
    
    func placeSelected(_ place: Place) {
        let houseNumbers = place.desc.components(separatedBy: " ")[0]
        place.getDetails({ (thePlaceDetails) -> () in
            let fullAddress = thePlaceDetails.fullAddress.components(separatedBy: " ")[0]
            if self.isNumeric(fullAddress) {
                print(place.desc)
                GoogleAddress.address = thePlaceDetails.fullAddress
            } else {
                GoogleAddress.address = houseNumbers + " " + thePlaceDetails.fullAddress
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateComposeMessageLabel"), object: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func isNumeric(_ a: String) -> Bool {
        return Int(a) != nil
    }
    
    func placeViewClosed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
