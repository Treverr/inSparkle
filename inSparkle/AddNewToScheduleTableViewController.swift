//
//  AddNewToScheduleTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/2/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class AddNewToScheduleTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var weekPicker: UIPickerView!
    @IBOutlet weak var weekStartingLabel: UILabel!
    @IBOutlet weak var weekEndingLabel: UILabel!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var typeSegControl: UISegmentedControl!
    
    
    var weekList = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        setLastUsedTypeSegmentController()
        
        weekPicker.delegate = self
        weekPicker.dataSource = self
        customerNameTextField.delegate = self
        
        self.tableView.allowsSelection = false
        
        
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
        
        return false
    }
    
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
    
    @IBAction func typeSegControl(sender: AnyObject) {
        DataManager.lastUsedTypeSegment = typeSegControl.selectedSegmentIndex
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
    
}
