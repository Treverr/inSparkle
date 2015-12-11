//
//  AddNewToScheduleTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/2/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import GooglePlacesAutocomplete
//import PhoneNumberKit

class AddNewToScheduleTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var weekPicker: UIPickerView!
    @IBOutlet weak var weekStartingLabel: UILabel!
    @IBOutlet weak var weekEndingLabel: UILabel!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var typeSegControl: UISegmentedControl!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    
    var weekList = [PFObject]()
    var phoneNumber : String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        setLastUsedTypeSegmentController()
        
        weekPicker.delegate = self
        weekPicker.dataSource = self
        customerNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        self.tableView.allowsSelection = false
        
        addressLabel.userInteractionEnabled = true
        let googlePlacesAPI : Selector = "googlePlacesAPI"
        let googlePlacesAPITapGesture = UITapGestureRecognizer(target: self, action: googlePlacesAPI)
        googlePlacesAPITapGesture.numberOfTapsRequired = 1
        addressLabel.addGestureRecognizer(googlePlacesAPITapGesture)
        
        weekPicker.userInteractionEnabled = true
        let weekPickerMakeAllOthersResign : Selector = "weekPickerMakeAllOthersResign"
        let weekPickerTapGesture = UITapGestureRecognizer(target: self, action: weekPickerMakeAllOthersResign)
        weekPickerTapGesture.numberOfTapsRequired = 1
        weekPicker.addGestureRecognizer(weekPickerTapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedAddressLabel", name: "NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getDatesFromParse()
    }
    
    
    
    func textFieldDidBeginEditing(textField : UITextField) {
        
    }
    
    func getDatesFromParse() {
        
        let query = PFQuery(className: "ScheduleWeekList")
        query.whereKey("weekEnd", greaterThan: NSDate())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.findObjectsInBackgroundWithBlock { (weeks:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print(weeks!)
                if weeks == nil || weeks?.count == 0 {
                    // What to do??
                } else {
                    for week in weeks! {
                        self.weekList.append(week)
                        print(self.weekList)
                        self.weekPicker.reloadAllComponents()
                    }
                }
                
            }
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weekList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if weekList.count > 0 && weekPicker.selectedRowInComponent(0) == 0 {
            let weekStart  = weekList[0].valueForKey("weekStart") as! NSDate
            weekStartingLabel.text = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekStart)
            weekStartingLabel.textColor = UIColor.blackColor()
            let weekEnd = weekList[0].valueForKey("weekEnd") as! NSDate
            weekEndingLabel.text = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekEnd)
            weekEndingLabel.textColor = UIColor.blackColor()
        }
        
        let weekTitle : String!
        let weekStartDate : NSDate!
        let weekEndDate : NSDate!
        let remaining : Int!
        
        weekStartDate = weekList[row].valueForKey("weekStart") as! NSDate
        weekEndDate = weekList[row].valueForKey("weekEnd") as! NSDate
        remaining = weekList[row].valueForKey("apptsRemain") as? Int
        
        let global = GlobalFunctions()
        let weekStartString = global.stringFromDateShortStyleNoTimezone(weekStartDate)
        let weekEndString = global.stringFromDateShortStyleNoTimezone(weekEndDate)
        
        weekTitle = "\(weekStartString) - \(weekEndString) (\(remaining))"
        
        return weekTitle
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if !pickerView.isFirstResponder() {
            customerNameTextField.resignFirstResponder()
            addressLabel.resignFirstResponder()
            phoneNumberTextField.resignFirstResponder()
        }
        
        let weekStartDate : NSDate = weekList[row].valueForKey("weekStart") as! NSDate
        let weekEndDate : NSDate = weekList[row].valueForKey("weekEnd") as! NSDate
        
        let weekStartString = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekStartDate)
        let weekEndString = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekEndDate)
        
        weekStartingLabel.text = weekStartString
        weekStartingLabel.textColor = UIColor.blackColor()
        weekEndingLabel.text = weekEndString
        weekEndingLabel.textColor = UIColor.blackColor()
    }
    
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if customerNameTextField.isFirstResponder() {
            customerNameTextField.resignFirstResponder()
            return true
        }
        
//        if phoneNumberTextField.isFirstResponder() {
//            
//            do {
//                let phoneNumber = try PhoneNumber(rawNumber:phoneNumberTextField.text!)
//                phoneNumberTextField.text! = phoneNumber.toNational()
//            } catch {
//                print("error")
//            }
//        }
        
        return false
    }
    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
//        if phoneNumberTextField.isFirstResponder() {
//            
//            do {
//                let phoneNumber = try PhoneNumber(rawNumber:phoneNumberTextField.text!)
//                phoneNumberTextField.text! = phoneNumber.toNational()
//            } catch {
//                print("error")
//            }
//        }
//        return false
//    }
    
    @IBAction func saveButton(sender: AnyObject) {
        if customerNameTextField.text!.isEmpty {
            displayError("Missing Field", message: "There is a field missing, check your entries and try again")
        } else {
            
            let customerName = customerNameTextField.text?.capitalizedString
            let weekStartingString = weekStartingLabel.text
            let weekEndingString = weekEndingLabel.text
            
            var weekStartDate : NSDate?
            var weekEndDate : NSDate?
            
            if weekStartingString != nil {
                weekStartDate = GlobalFunctions().dateFromShortDateString(weekStartingString!)
            }
            
            if weekEndingString != nil {
                weekEndDate = GlobalFunctions().dateFromShortDateString(weekEndingString!)
            }
            
            let schObj = ScheduleObject()
            ScheduleObject.registerSubclass()
            schObj.customerName = customerName!
            schObj.weekStart = weekStartDate!
            schObj.weekEnd = weekEndDate!
            schObj.isActive = true
            schObj.type = segmentControl(typeSegControl.selectedSegmentIndex)
            schObj.saveEventually { (success: Bool, error : NSError?) -> Void in
                if error == nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayError(title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Oops", style: .Default, handler: nil)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func segmentControl(selected : Int) -> String {
        var returnValue : String!
        
        switch selected {
        case 0: returnValue = "Opening"
        case 1: returnValue = "Closing"
        default: break
        }
        
        return returnValue
        
    }
    
    func setLastUsedTypeSegmentController() {
        if DataManager.lastUsedTypeSegment != nil {
            switch DataManager.lastUsedTypeSegment {
            case 0: typeSegControl.selectedSegmentIndex = 0
            case 1: typeSegControl.selectedSegmentIndex = 1
            default: break
            }
        }
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
    
    var isKeyboardShowing : Bool?
    var kbHeight: CGFloat?
    var showUIKeyboard : Bool?
    
    func keyboardWillShow(notification : NSNotification) {
        
        if isKeyboardShowing == true {
            return
        } else {
            if let userInfo = notification.userInfo {
                if let keyboardSize = (userInfo [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    kbHeight = keyboardSize.height
                    self.animateTextField(true)
                    isKeyboardShowing = true
                }
            }
        }
        
    }
    
    
    
    func keyboardWillHide(notification : NSNotification) {
        self.animateTextField(false)
        isKeyboardShowing = false
    }
    
    func animateTextField(up: Bool) {
        if kbHeight == nil {
            return
        } else {
            if customerNameTextField.isFirstResponder() {
                
            } else {
                let movement = (up ? -kbHeight! + 150 : kbHeight! - 150)
                UIView.animateWithDuration(0.3, animations: {
                    self.view.frame = CGRectOffset(self.view.frame, 0, movement)
                })
            }
        }
        
    }
    
    func weekPickerMakeAllOthersResign() {
        if !weekPicker.isFirstResponder() {
            customerNameTextField.resignFirstResponder()
            addressLabel.resignFirstResponder()
            phoneNumberTextField.resignFirstResponder()
        }
    }
    
}

extension AddNewToScheduleTableViewController : GooglePlacesAutocompleteDelegate {
    
    func placeSelected(place: Place) {
        GoogleAddress.address = place.description
        NSNotificationCenter.defaultCenter().postNotificationName("NotifyUpdateAddressLabelFromGoogleAutocompleteAPI", object: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}
