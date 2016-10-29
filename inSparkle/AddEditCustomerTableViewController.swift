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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            self.firstNameTextField.text = self.customer?.firstName?.capitalized
            self.lastNameTextField.text = self.customer?.lastName?.capitalized
            self.phoneNumberTextField.text = self.customer?.phoneNumber.capitalized
            if self.customer?.addressStreet != nil {
                self.addressLabel.textColor = UIColor.black
                self.addressLabel.text = "\(self.customer!.addressStreet.capitalized) \n" + "\(self.customer!.addressCity.capitalized), \(self.customer!.addressState.uppercased()) \(self.customer!.ZIP)"
            }
        }
        
        phoneNumberTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(AddEditCustomerTableViewController.updatedAddressLabel), name: NSNotification.Name(rawValue: "NotifyUpdateAddressLabelFromGoogleAutocompleteAPI"), object: nil)
        
        enableSaveButton(false)

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
    
    func enableSaveButton(_ enabled : Bool) {
        saveUpdateButton.isEnabled = enabled
        if enabled {
            saveUpdateButton.tintColor = UIColor.blue
        } else {
            saveUpdateButton.tintColor = UIColor.lightGray
        }
    }
    
    var updatedAddress = false
    
    func updatedAddressLabel() {
        updatedAddress = true
        addressLabel.text = GoogleAddress.address
        addressLabel.textColor = UIColor.black
        GoogleAddress.address = nil
        enableSaveButton(true)
    }
    
    @IBAction func saveUpdate(_ sender: AnyObject) {
        
        saveUpdateButton.setTitle("Saving...", for: UIControlState())
        var accountNumber : String?
        var oldAccountNumber : String?
        var emailAccountNumber : String?
        let name : String! = firstNameTextField.text! + " " + lastNameTextField.text!
        let address : String! = addressLabel.text!
        let phoneNumber : String = phoneNumberTextField.text!
        if self.customer != nil {
            oldAccountNumber = customer?.accountNumber
            var firstSeven : String!
            if phoneNumberTextField.text?.characters.count > 7 {
                let nonFormttedArray = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
                let acctNumber = nonFormttedArray.joined(separator: "")
                firstSeven = acctNumber.substring(from: phoneNumber.characters.index(phoneNumber.startIndex, offsetBy: 3))
                print(firstSeven)
                accountNumber = firstSeven
                emailAccountNumber = oldAccountNumber! + " --> " + accountNumber!
            }
        } else {
            var firstSeven : String!
            if phoneNumberTextField.text?.characters.count > 7 {
                let nonFormttedArray = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
                let acctNumber = nonFormttedArray.joined(separator: "")
                firstSeven = acctNumber.substring(from: phoneNumber.characters.index(phoneNumber.startIndex, offsetBy: 3))
                print(firstSeven)
                accountNumber = firstSeven
                emailAccountNumber = accountNumber
            }
        }
        CloudCode.AddUpdateCustomerRecord(emailAccountNumber, name: name, address: address, phoneNumber: phoneNumber)
        var addressStreet : String?
        var addressCity : String?
        var addressState : String?
        var addressZIP : String?
        
        if updatedAddress == true {
            let stringArray = address.components(separatedBy: ",")
            addressStreet = stringArray[0]
            addressCity = stringArray[1]
            let cityStateArray = stringArray[2].components(separatedBy: " ")
            addressState = cityStateArray[1]
            addressZIP = cityStateArray[2]
        }
      
        
        if self.customer == nil {
            self.customer = CustomerData()
        }
        
        self.customer?.accountNumber = accountNumber!
        self.customer?.firstName = firstNameTextField.text!.uppercased()
        self.customer?.lastName = lastNameTextField.text!.uppercased()
        self.customer?.fullName = lastNameTextField.text!.uppercased() + ", " + firstNameTextField.text!.uppercased()
        if updatedAddress == true {
            self.customer?.addressStreet = addressStreet!.uppercased()
            self.customer?.addressCity = addressCity!.uppercased()
            self.customer?.addressState = addressState!.uppercased()
            self.customer?.ZIP = String(addressZIP!)
        }
        self.customer?.phoneNumber = phoneNumberTextField.text!
        self.customer?.currentBalance = 0
        self.customer?.customerOpened = Date()
        self.customer?.saveInBackground(block: { (saved : Bool, error : Error?) in
            if error == nil {
                CustomerLookupObjects.slectedCustomer = self.customer!
                
                if CustomerLookupObjects.fromVC == "AddSchedule" {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFieldsOnSchedule"), object: nil)
                }
                if CustomerLookupObjects.fromVC == "NewMessage" {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFieldsOnNewMessage"), object: nil)
                }
                
                self.dismiss(animated: true, completion: nil)
                CustomerLookupObjects.fromVC = nil
            } else {
                print(error)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 3 {
            googlePlacesAPI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AddEditCustomers.theCustomer = nil
        GoogleAddress.address = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumberKit().parse(phoneNumberTextField.text!)
                phoneNumberTextField.text = String(phoneNumber.nationalNumber)
            } catch {
                
            }
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumberKit().parse(phoneNumberTextField.text!)
                phoneNumberTextField.text! = String(phoneNumber.nationalNumber)
            } catch {
                print("error")
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton(true)
    }
    
}

extension AddEditCustomerTableViewController : GooglePlacesAutocompleteDelegate {
    
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotifyUpdateAddressLabelFromGoogleAutocompleteAPI"), object: nil)
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
