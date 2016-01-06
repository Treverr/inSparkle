//
//  AddEditCustomerTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import GooglePlacesAutocomplete
import Parse
import PhoneNumberKit

class AddEditCustomerTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var saveUpdateButton: UIButton!
    
    var customer : CustomerData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customer = AddEditCustomers.theCustomer
    
        if AddEditCustomers.theCustomer != nil {
            self.firstNameTextField.text = self.customer?.firstName?.capitalizedString
            self.lastNameTextField.text = self.customer?.lastName?.capitalizedString
            self.phoneNumberTextField.text = self.customer?.phoneNumber.capitalizedString
            if self.customer?.addressStreet != nil || self.customer?.addressStreet != "" {
                self.addressLabel.textColor = UIColor.blackColor()
                self.addressLabel.text = "\(self.customer!.addressStreet.capitalizedString) \n" + "\(self.customer!.addressCity.capitalizedString), \(self.customer!.addressState.uppercaseString) \(self.customer!.ZIP)"
            }
        }
        
        phoneNumberTextField.delegate = self
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedAddressLabel", name: "NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)

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
    
    func updatedAddressLabel() {
        addressLabel.text = GoogleAddress.address
        addressLabel.textColor = UIColor.blackColor()
    }
    
    @IBAction func saveUpdate(sender: AnyObject) {
        saveUpdateButton.setTitle("Saving...", forState: .Normal)
        var accountNumber : String?
        let name : String! = firstNameTextField.text! + " " + lastNameTextField.text!
        let address : String! = addressLabel.text!
        let phoneNumber : String = phoneNumberTextField.text!
        if self.customer != nil {
            accountNumber = customer?.accountNumber
        } else {
            var firstSeven : String!
            if phoneNumberTextField.text?.characters.count > 7 {
                let nonFormttedArray = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                let acctNumber = nonFormttedArray.joinWithSeparator("")
                firstSeven = acctNumber.substringFromIndex(phoneNumber.startIndex.advancedBy(3))
                print(firstSeven)
                accountNumber = firstSeven
            }
        }
        CloudCode.AddUpdateCustomerRecord(accountNumber, name: name, address: address, phoneNumber: phoneNumber)
        let stringArray = address.componentsSeparatedByString(",")
        let addressStreet = stringArray[0]
        let addressCity = stringArray[1]
        let cityStateArray = stringArray[2].componentsSeparatedByString(" ")
        let addressState = cityStateArray[1]
        let addressZIP = cityStateArray[2]
        
        if self.customer == nil {
            self.customer = CustomerData()
        }
        
        self.customer?.accountNumber = accountNumber!
        self.customer?.firstName = firstNameTextField.text!.uppercaseString
        self.customer?.lastName = lastNameTextField.text!.uppercaseString
        self.customer?.fullName = lastNameTextField.text!.uppercaseString + ", " + firstNameTextField.text!.uppercaseString
        self.customer?.addressStreet = addressStreet.uppercaseString
        self.customer?.addressCity = addressCity.uppercaseString
        self.customer?.addressState = addressState.uppercaseString
        self.customer?.phoneNumber = phoneNumberTextField.text!
        self.customer?.ZIP = String(addressZIP)
        self.customer?.currentBalance = 0
        self.customer?.customerOpened = NSDate()
        self.customer?.saveInBackground()
        
        
        CustomerLookupObjects.slectedCustomer = self.customer!
        
        if CustomerLookupObjects.fromVC == "AddSchedule" {
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateFieldsOnSchedule", object: nil)
        }
        if CustomerLookupObjects.fromVC == "NewMessage" {
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateFieldsOnNewMessage", object: nil)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        CustomerLookupObjects.fromVC = nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 3 {
            googlePlacesAPI()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        AddEditCustomers.theCustomer = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumber(rawNumber: phoneNumberTextField.text!)
                phoneNumberTextField.text = phoneNumber.toNational()
            } catch {
                
            }
        }
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumber(rawNumber:phoneNumberTextField.text!)
                phoneNumberTextField.text! = phoneNumber.toNational()
            } catch {
                print("error")
            }
        }
        return true
    }
    
}

extension AddEditCustomerTableViewController : GooglePlacesAutocompleteDelegate {
    
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
        NSNotificationCenter.defaultCenter().postNotificationName("NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)
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