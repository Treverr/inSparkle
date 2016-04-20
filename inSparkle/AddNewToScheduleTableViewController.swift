//
//  AddNewToScheduleTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/2/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import PhoneNumberKit

class AddNewToScheduleTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var weekPicker: UIPickerView!
    @IBOutlet weak var weekStartingLabel: UILabel!
    @IBOutlet weak var weekEndingLabel: UILabel!
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var typeSegControl: UISegmentedControl!
    @IBOutlet var addressLabel: UITextView!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var typeOfWinterCoverLabel: UILabel!
    @IBOutlet var typeOfWinterCoverPicker: UIPickerView!
    @IBOutlet var aquadoorYesNo: UISegmentedControl!
    @IBOutlet var dateClosingPicker: UIPickerView!
    @IBOutlet weak var confirmButton : UIButton!
    @IBOutlet var locationOfEssentialItemsLabel: UILabel!
    @IBOutlet var importantTextView: UITextView!
    @IBOutlet var selectClosingDate: UILabel!
    @IBOutlet var generatePDFButton: UIBarButtonItem!
    
    var weekList = [PFObject]()
    var typeOfWinterCover = [String]()
    var phoneNumber : String! = nil
    var weeksNeedsSet = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFields", name: "UpdateFieldsOnSchedule", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        var isOpening : Bool?
        
        if AddNewScheduleObjects.isOpening != nil {
            isOpening = AddNewScheduleObjects.isOpening as Bool
            print(AddNewScheduleObjects.isOpening)
            if (isOpening!) {
                self.navigationItem.title = "Schedule Opening"
            } else {
                self.navigationItem.title = "Schedule Closing"
            }
        }
        
        locationEssentialItems.delegate = self
        notesTextView.delegate = self
        
        if AddNewScheduleObjects.scheduledObject != nil {
            weeksNeedsSet = false
            let object = AddNewScheduleObjects.scheduledObject!
            customerNameTextField.text = object.customerName.capitalizedString
            addressLabel.text = object.customerAddress.capitalizedString
            phoneNumberTextField.text = object.customerPhone
            weekStartingLabel.text = GlobalFunctions().stringFromDateShortStyle(object.weekStart)
            weekEndingLabel.text = GlobalFunctions().stringFromDateShortStyle(object.weekEnd)
            typeOfWinterCoverLabel.text = object.coverType
            if object.aquaDoor != nil {
                if object.aquaDoor == true {
                    aquadoorYesNo.selectedSegmentIndex = 0
                } else {
                    aquadoorYesNo.selectedSegmentIndex = 1
                }
            }
            locationEssentialItems.text = object.locEssentials
            if object.bringChem == true {
                bringCloseChemYesNo.selectedSegmentIndex = 0
            } else {
                bringCloseChemYesNo.selectedSegmentIndex = 1
            }
            if object.takeTrash == true {
                takeTrashSeg.selectedSegmentIndex = 0
            } else {
                takeTrashSeg.selectedSegmentIndex = 1
            }
            if object.notes != nil {
                notesTextView.text = object.notes
            }
            
            if object.type == "Opening" {
                isOpening = true
            } else {
                isOpening = false
            }
            
            if AddNewScheduleObjects.scheduledObject != nil {
                if AddNewScheduleObjects.scheduledObject!.confirmedDate != nil {
                    selectClosingDate.text! = GlobalFunctions().stringFromDateShortStyle(AddNewScheduleObjects.scheduledObject!.confirmedDate!)
                }
            }
            
        }
        
        if (isOpening!) {
            locationOfEssentialItemsLabel.text = "Where to store winter accessories?"
            importantTextView.text = "Customer must have the following done, to avoid any additional charges:"
                + "\n -WATER LEVEL IN POOL RAISED TO MIDDLE OF SKIMMER"
                + "\n -ELECTRICITY TURNED ON TO PUMP AND FILTER"
                + "\n -WATER PUMPED OFF COVER AND LEAVES CLEANED OFF"
        } else {
            importantTextView.text = "Customer must have the following done, to avoid any additional charges:"
                + "\n -POOL VACUUMED OUT"
                + "\n -WATER LEVEL LOWERED TO 1/2” BELOW THE SKIMMER (OVERFILL FOR GROUND WATER, ELECTRIC COVERS DON’T LOWER WATER LEVEL)"
        }
        
        setTypes()
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        weekPicker.delegate = self
        weekPicker.dataSource = self
        dateClosingPicker.dataSource = self
        customerNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        dateClosingPicker.delegate = self
        
        typeOfWinterCoverPicker.delegate = self
        typeOfWinterCoverPicker.dataSource = self
        
        weekPicker.userInteractionEnabled = true
        let weekPickerMakeAllOthersResign : Selector = "weekPickerMakeAllOthersResign"
        let weekPickerTapGesture = UITapGestureRecognizer(target: self, action: weekPickerMakeAllOthersResign)
        weekPickerTapGesture.numberOfTapsRequired = 1
        weekPicker.addGestureRecognizer(weekPickerTapGesture)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getDatesFromParse()
    }
    
    func setTypes() {
        typeOfWinterCover = [
            "Solid w/ Water Tubes",
            "Electric",
            "Solid Safety",
            "Mesh Safety",
            "Solid w/ Winch and Cable (AG Only)",
            "Other (See Notes)"]
    }
    
    func textFieldDidBeginEditing(textField : UITextField) {
        
    }
    
    func getDatesFromParse() {
        
        var isOpeningWeek : Bool!
        
        if AddNewScheduleObjects.isOpening != nil {
            isOpeningWeek = AddNewScheduleObjects.isOpening as Bool
        } else {
            if AddNewScheduleObjects.scheduledObject?.type == "Opening" {
                isOpeningWeek = true
            } else {
                isOpeningWeek = false
            }
        }
        
        let query = PFQuery(className: "ScheduleWeekList")
        query.whereKey("weekEnd", greaterThan: NSDate())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: isOpeningWeek)
        query.addAscendingOrder("weekStart")
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
        
        var whatToReturn : Int? = nil
        
        if pickerView == weekPicker {
            whatToReturn = weekList.count
        }
        
        if pickerView == typeOfWinterCoverPicker {
            whatToReturn = typeOfWinterCover.count
        }
        
        if pickerView == dateClosingPicker {
            whatToReturn = dateWeekRange.count
        }
        
        return whatToReturn!
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var whatToReturn : String? = nil
        
        if pickerView == weekPicker {
            if weekList.count > 0 && weekPicker.selectedRowInComponent(0) == 0 {
                if AddNewScheduleObjects.scheduledObject == nil {
                    if weeksNeedsSet {
                        let weekStart  = weekList[0].valueForKey("weekStart") as! NSDate
                        weekStartingLabel.text = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekStart)
                        weekStartingLabel.textColor = UIColor.blackColor()
                        let weekEnd = weekList[0].valueForKey("weekEnd") as! NSDate
                        weekEndingLabel.text = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekEnd)
                        weekEndingLabel.textColor = UIColor.blackColor()
                        weeksNeedsSet = false
                        let theweeeeek = weekList[0]
                        self.selectedWeekObj = theweeeeek as! WeekList
                    }
                }
                
                if dateWeekRange.count == 0 {
                    dateForDatePicker()
                }
                
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
            
            whatToReturn = weekTitle
            
        }
        
        if pickerView == typeOfWinterCoverPicker {
            if typeOfWinterCover.count > 0 && pickerView.selectedRowInComponent(0) == 0 {
                if pickerView.hidden == false {
                    typeOfWinterCoverLabel.textColor = UIColor.blackColor()
                    if AddNewScheduleObjects.scheduledObject == nil {
                        typeOfWinterCoverLabel.text = typeOfWinterCover.first
                    } else {
                        typeOfWinterCoverLabel.text = AddNewScheduleObjects.scheduledObject!.coverType
                    }
                    
                }
                
            }
            whatToReturn = typeOfWinterCover[row]
        }
        
        if pickerView == dateClosingPicker {
            if pickerView.hidden == false {
                whatToReturn = dateWeekRange[row]
                if AddNewScheduleObjects.scheduledObject?.confirmedDate == nil {
                    selectClosingDate.text = dateWeekRange[0]
                }
                selectClosingDate.textColor = UIColor.blackColor()
            }
        }
        
        return whatToReturn!
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    var selectedWeekObj : WeekList?
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if pickerView == weekPicker {
            
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
            let theObj = self.weekList[row] as! WeekList
            selectedWeekObj = theObj
        }
        
        if pickerView == typeOfWinterCoverPicker {
            if !pickerView.isFirstResponder() {
                customerNameTextField.resignFirstResponder()
                addressLabel.resignFirstResponder()
                phoneNumberTextField.resignFirstResponder()
                weekPicker.resignFirstResponder()
                
                typeOfWinterCoverLabel.text! = typeOfWinterCover[row]
                
            }
        }
        
        if pickerView == dateClosingPicker {
            selectClosingDate.text! = dateWeekRange[row]
            selectClosingDate!.textColor = UIColor.blackColor()
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == customerNameTextField {
            customerNameTextField.resignFirstResponder()
            return true
        }
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumber(rawNumber:phoneNumberTextField.text!)
                phoneNumberTextField.text! = phoneNumber.toNational()
            } catch {
                print("error")
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if theWeekPickerHidden == false || theCoverTypePickerHidden == false {
            weekPicker.hidden = true
            theWeekPickerHidden = true
            typeOfWinterCoverPicker.hidden = true
            theCoverTypePickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if theWeekPickerHidden == false || theCoverTypePickerHidden == false {
            weekPicker.hidden = true
            theWeekPickerHidden = true
            typeOfWinterCoverPicker.hidden = true
            theCoverTypePickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if textView == notesTextView {
            let indexPath = NSIndexPath(forRow: 12, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
        
        if textView == locationEssentialItems {
            let indexPath = NSIndexPath(forRow: 9, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
        
    }
    
    var confirmedWith : UITextField!
    
    @IBAction func confirmButton(sender : AnyObject) {
        if selectClosingDate.text == "Not Set" {
            let error = UIAlertController(title: "Select Date", message: "Please set a date before attempting to confirm a POC", preferredStyle: .Alert)
            let okay = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            error.addAction(okay)
            self.presentViewController(error, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Confirmed with?", message: "Please enter the name of the peson you spoke to when confirming", preferredStyle: .Alert)
            let confirmButton = UIAlertAction(title: "Confirm", style: .Default) { (action) -> Void in
                print(self.confirmedWith.text!)
                self.saveButton(sender)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "name"
                textField.keyboardType = .Default
                self.confirmedWith = textField
            }
            alert.addAction(confirmButton)
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        if customerNameTextField.text!.isEmpty || addressLabel.text!.isEmpty || phoneNumberTextField.text!.isEmpty || typeOfWinterCoverLabel.text!.isEmpty ||  locationEssentialItems.text.isEmpty {
            displayError("Missing Field", message: "There is a field missing, check your entries and try again")
        } else {
            
            let customerName = customerNameTextField.text?.capitalizedString
            let weekStartingString = weekStartingLabel.text
            let weekEndingString = weekEndingLabel.text
            let coverType = typeOfWinterCoverLabel.text
            let locationOfEss = locationEssentialItems.text!
            let bringCloseChem = bringChem
            let takeTheTrash = takeTrash
            let theNotes = notesTextView
            
            var weekStartDate : NSDate?
            var weekEndDate : NSDate?
            
            if weekStartingString != nil {
                weekStartDate = GlobalFunctions().dateFromShortDateString(weekStartingString!)
            }
            
            if weekEndingString != nil {
                weekEndDate = GlobalFunctions().dateFromShortDateString(weekEndingString!)
            }
            
            var schObj : ScheduleObject!
            
            if AddNewScheduleObjects.scheduledObject == nil {
                schObj = ScheduleObject()
            } else {
                schObj = AddNewScheduleObjects.scheduledObject
            }
            
            ScheduleObject.registerSubclass()
            if sender as! NSObject == confirmButton {
                schObj.confirmedWith = self.confirmedWith.text!.capitalizedString
                schObj.confirmedDate = NSDate()
                schObj.confrimed = true
            }
            schObj.customerName = customerName!.capitalizedString
            schObj.customerAddress = addressLabel.text!.stringByReplacingOccurrencesOfString("\n", withString: " ").capitalizedString
            schObj.customerPhone = phoneNumberTextField.text!
            schObj.weekStart = weekStartDate!
            schObj.weekEnd = weekEndDate!
            if self.selectedWeekObj != nil {
                schObj.weekObj = self.selectedWeekObj!
            }
            schObj.isActive = true
            if self.accountNumber != nil || schObj.accountNumber != nil {
                if schObj.accountNumber != nil {
                    schObj.accountNumber = schObj.accountNumber
                }
                if self.accountNumber != nil {
                    schObj.accountNumber = self.accountNumber
                }
            } else {
                schObj.accountNumber = ""
            }
            if AddNewScheduleObjects.isOpening != nil {
                if AddNewScheduleObjects.isOpening == true {
                    schObj.type = "Opening"
                } else {
                    schObj.type = "Closing"
                }
            }
            schObj.coverType = coverType!
            if AddNewScheduleObjects.isOpening != nil {
                if AddNewScheduleObjects.isOpening == false {
                    schObj.aquaDoor = aquadoor
                }
            }
            schObj.locEssentials = locationOfEss
            schObj.bringChem = bringCloseChem
            schObj.takeTrash = takeTheTrash
            schObj.notes = theNotes.text!
            if selectClosingDate.text != "Not Set" {
                schObj.confirmedDate = GlobalFunctions().dateFromShortDateString(selectClosingDate.text!)
                schObj.confrimedBy = PFUser.currentUser()?.username!.capitalizedString
            } else {
                schObj.confrimed = false
                schObj.removeObjectForKey("confrimedBy")
                schObj.removeObjectForKey("confirmedDate")
            }
            schObj.saveEventually { (success: Bool, error : NSError?) -> Void in
                if success {
                    if sender as! NSObject == self.generatePDFButton {
                        let sb = UIStoryboard(name: "OpeningPDFTemplate", bundle: nil)
                        let vc = sb.instantiateViewControllerWithIdentifier("PoolOpeningTemplate")
                        POCReportData.POCData = [schObj]
                        self.presentViewController(vc, animated: true, completion: { 
                            if let overlayView = self.view.viewWithTag(6969) {
                                overlayView.removeFromSuperview()
                            }
                            if let activityIndicator = self.view.viewWithTag(6868) {
                                activityIndicator.removeFromSuperview()
                            }
                        })
                    } else {
                        var isOpening : Bool!
                        if schObj.type == "Opening" {
                            isOpening = true
                        } else {
                            isOpening = false
                        }
                        
                        GlobalFunctions().updateWeeksAppts()
                        
                        AddNewScheduleObjects.scheduledObject = nil
                        AddNewScheduleObjects.isOpening = nil
                        self.dismissViewControllerAnimated(true, completion: nil)
                        NSNotificationCenter.defaultCenter().postNotificationName("NotifyScheduleTableToRefresh", object: nil)
                        AddNewScheduleObjects.isOpening = nil
                        if self.selectClosingDate.text != "Not Set" && sender as! NSObject == self.confirmButton {
                            NSNotificationCenter.defaultCenter().postNotificationName("NotifyAppointmentConfirmed", object: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName("NotifyScheduleTableToRefresh", object: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        AddNewScheduleObjects.scheduledObject = nil
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
    
    
    var isKeyboardShowing : Bool?
    var kbHeight: CGFloat?
    var showUIKeyboard : Bool?
    var hasKeyboard : Bool?
    
    func keyboardWillShow(notification : NSNotification) {
        
        var userInfo: [NSObject : AnyObject] = notification.userInfo!
        let keyboardFrame: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let keyboard: CGRect = self.view.convertRect(keyboardFrame, fromView: self.view.window)
        let height: CGFloat = self.view.frame.size.height
        if ((keyboard.origin.y + keyboard.size.height) > height) {
            self.hasKeyboard = true
        }
        
        let toolbarHeight : CGFloat?
        
        if !notesTextView.isFirstResponder() {
            return
        } else {
            
            if isKeyboardShowing == true {
                return
            } else {
                if let userInfo = notification.userInfo {
                    if let keyboardSize = (userInfo [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                        if self.hasKeyboard == true && notesTextView.isFirstResponder() {
                            kbHeight = 25
                        } else {
                            kbHeight = keyboardSize.height - 75
                        }
                        self.animateTextField(true)
                        isKeyboardShowing = true
                    }
                }
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        if (isKeyboardShowing != nil) {
            if isKeyboardShowing! {
                self.animateTextField(false)
                isKeyboardShowing = false
            }
        }
    }
    
    func animateTextField(up: Bool) {
        if kbHeight == nil {
            return
        } else {
            if customerNameTextField.isFirstResponder() {
                
            } else {
                let movement = (up ? -kbHeight! : kbHeight!)
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
    
    var theWeekPickerHidden = true
    var theCoverTypePickerHidden = true
    
    let weekPickerIndexPath : NSIndexPath = NSIndexPath(forItem: 4, inSection: 0)
    let typePickerIndexPath : NSIndexPath = NSIndexPath(forItem: 7, inSection: 0)
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        
        if theWeekPickerHidden == false {
            weekPicker.hidden = true
        } else {
            weekPicker.hidden = false
        }
        
        if theCoverTypePickerHidden == false {
            typeOfWinterCoverPicker.hidden = true
        } else {
            typeOfWinterCoverPicker.hidden = false
        }
        
        if indexPath.section  == 0 && indexPath.row == 3 {
            toggleWeekPicker()
        }
        
        if indexPath.section == 0 && indexPath.row == 5 {
            toggleWeekPicker()
        }
        
        if indexPath.section == 0 && indexPath.row == 6 {
            toggleTypePicker()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 8 {
            if AddNewScheduleObjects.isOpening == nil {
                
            } else {
                if AddNewScheduleObjects.isOpening == true {
                    return 0
                }
            }
            
        }
        
        if AddNewScheduleObjects.scheduledObject == nil {
            if indexPath.section == 1 && indexPath.row == 1 {
                return 0
            }
        }
        
        if theWeekPickerHidden == true && indexPath == weekPickerIndexPath {
            return 0
        }
        
        if theCoverTypePickerHidden == true && indexPath == typePickerIndexPath {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
        
        
    }
    
    func toggleWeekPicker() {
        
        theWeekPickerHidden = !theWeekPickerHidden
        theCoverTypePickerHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func toggleTypePicker() {
        
        theCoverTypePickerHidden = !theCoverTypePickerHidden
        theWeekPickerHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    var aquadoor : Bool = true
    
    @IBAction func aquaDoorYesNo(sender: AnyObject) {
        if aquadoorYesNo.selectedSegmentIndex == 0 {
            aquadoor = true
        }
        
        if aquadoorYesNo.selectedSegmentIndex == 1 {
            aquadoor = false
        }
    }
    
    @IBOutlet var locationEssentialItems: UITextView!
    
    @IBOutlet var bringCloseChemYesNo: UISegmentedControl!
    var bringChem : Bool = true
    
    @IBAction func bringChem(sender: AnyObject) {
        
        if bringCloseChemYesNo.selectedSegmentIndex == 0 {
            bringChem = true
        }
        
        if bringCloseChemYesNo.selectedSegmentIndex == 1 {
            bringChem = false
        }
        
    }
    
    @IBOutlet var takeTrashSeg: UISegmentedControl!
    var takeTrash : Bool = true
    
    @IBAction func takeTrash(sender: AnyObject) {
        
        if takeTrashSeg.selectedSegmentIndex == 0 {
            takeTrash = true
        }
        
        if takeTrashSeg.selectedSegmentIndex == 1 {
            
            takeTrash = false
        }
        
    }
    
    @IBOutlet var notesTextView: UITextView!
    var accountNumber : String?
    
    func updateFields() {
        
        var selectedCx = CustomerLookupObjects.slectedCustomer
        customerNameTextField.text = selectedCx!.firstName!.capitalizedString + " " + selectedCx!.lastName!.capitalizedString
        addressLabel.text = "\(selectedCx!.addressStreet.capitalizedString) \n \(selectedCx!.addressCity.capitalizedString), \(selectedCx!.addressState.uppercaseString) \(selectedCx!.ZIP)"
        phoneNumberTextField.text = selectedCx?.phoneNumber
        self.accountNumber = selectedCx?.accountNumber
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectCustomerForSchedule" {
            CustomerLookupObjects.fromVC = "AddSchedule"
        }
    }
    
    //    @IBAction func updateFields(seg : UIStoryboardSegue) {
    //
    //
    //        if seg.identifier == "updateFromAddEdit" {
    //            let fromVC = seg.sourceViewController as! AddEditCustomerTableViewController
    //
    //            customerNameTextField.text = fromVC.firstNameTextField.text!.capitalizedString + " " + fromVC.lastNameTextField.text!.capitalizedString
    //            addressLabel.text = fromVC.addressLabel.text
    //            addressLabel.textColor = UIColor.blackColor()
    //            phoneNumberTextField.text = fromVC.phoneNumberTextField.text
    //        } else {
    //            let fromVC = seg.sourceViewController as! CustomerLookupTableViewController
    //
    //            var selectedCx = fromVC.globalSelectedCx
    //
    //            customerNameTextField.text = selectedCx.firstName!.capitalizedString + " " + selectedCx.lastName!.capitalizedString
    //            addressLabel.text = "\(selectedCx.addressStreet) \n \(selectedCx.addressCity), \(selectedCx.addressState) \(selectedCx.ZIP)"
    //            phoneNumberTextField.text = selectedCx.phoneNumber
    //            self.accountNumber = selectedCx.accountNumber
    //        }
    //    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        customerNameTextField.resignFirstResponder()
        addressLabel.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
        locationEssentialItems.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
    
    var dateWeekRange = [String]()
    
    func dateForDatePicker() {
        if !weekEndingLabel.text!.isEmpty && !weekStartingLabel.text!.isEmpty {
            let startDate = GlobalFunctions().dateFromShortDateString(self.weekStartingLabel.text!)
            
            dateWeekRange.append("Not Set")
            dateWeekRange.append(GlobalFunctions().stringFromDateShortStyle(startDate))
            
            var daysToAdd = 0
            
            repeat {
                daysToAdd = daysToAdd + 1
                let comps = NSDateComponents()
                comps.setValue(daysToAdd, forComponent: NSCalendarUnit.Day)
                let addDate = NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: startDate, options: NSCalendarOptions(rawValue: 0))
                dateWeekRange.append(GlobalFunctions().stringFromDateShortStyle(addDate!))
            } while dateWeekRange.count < 7
            
            print(self.dateWeekRange)
            dateClosingPicker.reloadAllComponents()
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        AddNewScheduleObjects.scheduledObject = nil
    }
    
    @IBAction func generatePDF(sender: AnyObject) {
        self.saveButton(sender)
    }
    
}
