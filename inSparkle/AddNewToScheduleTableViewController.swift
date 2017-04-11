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
    @IBOutlet weak var smsSwitch: UISwitch!
    @IBOutlet weak var smsNumber: PhoneNumberTextField!
    
    var weekList = [PFObject]()
    var typeOfWinterCover = [String]()
    var phoneNumber : String! = nil
    var weeksNeedsSet = true
    var managerOverrode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewToScheduleTableViewController.updateFields), name: NSNotification.Name(rawValue: "UpdateFieldsOnSchedule"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewToScheduleTableViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewToScheduleTableViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(managerOverride), name: Notification.string(name: "ManagerOverrideApproved"), object: nil)
        
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
        
        smsNumber.isHidden = true
        smsSwitch.addTarget(self, action: #selector(self.smsSwitchStateChange), for: .valueChanged)
        
        if AddNewScheduleObjects.scheduledObject != nil {
            weeksNeedsSet = false
            let object = AddNewScheduleObjects.scheduledObject!
            customerNameTextField.text = object.customerName.capitalized
            addressLabel.text = object.customerAddress.capitalized
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
            
            if object.smsEnabled != nil {
                if object.smsEnabled! {
                    self.smsSwitch.setOn(true, animated: false)
                    self.smsNumber.isHidden = false
                    self.smsNumber.text = object.smsNumber!
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
        
        weekPicker.isUserInteractionEnabled = true
        let weekPickerMakeAllOthersResign : Selector = #selector(AddNewToScheduleTableViewController.weekPickerMakeAllOthersResign)
        let weekPickerTapGesture = UITapGestureRecognizer(target: self, action: weekPickerMakeAllOthersResign)
        weekPickerTapGesture.numberOfTapsRequired = 1
        weekPicker.addGestureRecognizer(weekPickerTapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func textFieldDidBeginEditing(_ textField : UITextField) {
        
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
        query.whereKey("weekEnd", greaterThan: Date())
        //        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: isOpeningWeek)
        query.addAscendingOrder("weekStart")
        query.findObjectsInBackground { (weeks:[PFObject]?, error: Error?) -> Void in
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var whatToReturn : String? = nil
        
        if pickerView == weekPicker {
            if weekList.count > 0 && weekPicker.selectedRow(inComponent: 0) == 0 {
                if AddNewScheduleObjects.scheduledObject == nil {
                    if weeksNeedsSet {
                        let weekStart  = weekList[0].value(forKey: "weekStart") as! Date
                        weekStartingLabel.text = GlobalFunctions().stringFromDateShortStyle(weekStart)
                        weekStartingLabel.textColor = UIColor.black
                        let weekEnd = weekList[0].value(forKey: "weekEnd") as! Date
                        weekEndingLabel.text = GlobalFunctions().stringFromDateShortStyle(weekEnd)
                        weekEndingLabel.textColor = UIColor.black
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
            let weekStartDate : Date!
            let weekEndDate : Date!
            let remaining : Int!
            
            weekStartDate = weekList[row].value(forKey: "weekStart") as! Date
            weekEndDate = weekList[row].value(forKey: "weekEnd") as! Date
            remaining = weekList[row].value(forKey: "apptsRemain") as? Int
            
            let global = GlobalFunctions()
            let weekStartString = global.stringFromDateShortStyleNoTimezone(weekStartDate)
            let weekEndString = global.stringFromDateShortStyleNoTimezone(weekEndDate)
            
            weekTitle = "\(weekStartString) - \(weekEndString) (\(remaining!))"
            
            whatToReturn = weekTitle
            
        }
        
        if pickerView == typeOfWinterCoverPicker {
            if typeOfWinterCover.count > 0 && pickerView.selectedRow(inComponent: 0) == 0 {
                if pickerView.isHidden == false {
                    typeOfWinterCoverLabel.textColor = UIColor.black
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
            if pickerView.isHidden == false {
                whatToReturn = dateWeekRange[row]
                if AddNewScheduleObjects.scheduledObject?.confirmedDate == nil {
                    selectClosingDate.text = dateWeekRange[0]
                }
                selectClosingDate.textColor = UIColor.black
            }
        }
        
        return whatToReturn!
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    var selectedWeekObj : WeekList?
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if pickerView == weekPicker {
            
            if !pickerView.isFirstResponder {
                customerNameTextField.resignFirstResponder()
                addressLabel.resignFirstResponder()
                phoneNumberTextField.resignFirstResponder()
            }
            
            let weekStartDate : Date = weekList[row].value(forKey: "weekStart") as! Date
            let weekEndDate : Date = weekList[row].value(forKey: "weekEnd") as! Date
            
            let weekStartString = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekStartDate)
            let weekEndString = GlobalFunctions().stringFromDateShortStyleNoTimezone(weekEndDate)
            
            weekStartingLabel.text = weekStartString
            weekStartingLabel.textColor = UIColor.black
            weekEndingLabel.text = weekEndString
            weekEndingLabel.textColor = UIColor.black
            let theObj = self.weekList[row] as! WeekList
            selectedWeekObj = theObj
        }
        
        if pickerView == typeOfWinterCoverPicker {
            if !pickerView.isFirstResponder {
                customerNameTextField.resignFirstResponder()
                addressLabel.resignFirstResponder()
                phoneNumberTextField.resignFirstResponder()
                weekPicker.resignFirstResponder()
                
                typeOfWinterCoverLabel.text! = typeOfWinterCover[row]
                
            }
        }
        
        if pickerView == dateClosingPicker {
            selectClosingDate.text! = dateWeekRange[row]
            selectClosingDate!.textColor = UIColor.black
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == customerNameTextField {
            customerNameTextField.resignFirstResponder()
            return true
        }
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumberKit().parse(phoneNumberTextField.text!)
                phoneNumberTextField.text! = PhoneNumberKit().format(phoneNumber, toType: .national)
            } catch {
                print("error")
            }
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            do {
                let phoneNumber = try PhoneNumberKit().parse(phoneNumberTextField.text!)
                phoneNumberTextField.text! = PhoneNumberKit().format(phoneNumber, toType: .national)
            } catch {
                print("error")
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if theWeekPickerHidden == false || theCoverTypePickerHidden == false {
            weekPicker.isHidden = true
            theWeekPickerHidden = true
            typeOfWinterCoverPicker.isHidden = true
            theCoverTypePickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if theWeekPickerHidden == false || theCoverTypePickerHidden == false {
            weekPicker.isHidden = true
            theWeekPickerHidden = true
            typeOfWinterCoverPicker.isHidden = true
            theCoverTypePickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if textView == notesTextView {
            let indexPath = IndexPath(row: 13, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        if textView == locationEssentialItems {
            let indexPath = IndexPath(row: 10, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
    }
    
    var confirmedWith : UITextField!
    
    @IBAction func confirmButton(_ sender : AnyObject) {
        if selectClosingDate.text == "Not Set" {
            let error = UIAlertController(title: "Select Date", message: "Please set a date before attempting to confirm a POC", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            error.addAction(okay)
            self.present(error, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Confirmed with?", message: "Please enter the name of the peson you spoke to when confirming", preferredStyle: .alert)
            let confirmButton = UIAlertAction(title: "Confirm", style: .default) { (action) -> Void in
                print(self.confirmedWith.text!)
                self.saveButton(sender)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (textField) -> Void in
                textField.placeholder = "name"
                textField.keyboardType = .default
                self.confirmedWith = textField
            }
            alert.addAction(confirmButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func weekManagerOverride(_ sender : AnyObject?) {
        
        let weekAlert = UIAlertController(title: "Overflow", message: "The week selected has 0 availabe slots, would you like to override this?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.performSave(sender)
        })
        let noButton = UIAlertAction(title: "No", style: .default, handler: { (action) in
            return
        })
        
        weekAlert.addAction(noButton)
        weekAlert.addAction(yesButton)
        self.present(weekAlert, animated: true, completion: nil)
        
    }
    
    func smsSwitchStateChange() {
        if smsSwitch.isOn {
            self.smsNumber.isHidden = false
            self.smsNumber.text = self.phoneNumberTextField.text!
        } else {
            self.smsNumber.isHidden = true
        }
    }
    
    func managerOverride(notification : Notification) {
        self.managerOverrode = true
        self.performSave(self)
    }
    
    func performSave(_ sender : AnyObject?) {
        let customerName = customerNameTextField.text?.capitalized
        let weekStartingString = weekStartingLabel.text
        let weekEndingString = weekEndingLabel.text
        let coverType = typeOfWinterCoverLabel.text
        let locationOfEss = locationEssentialItems.text!
        let bringCloseChem = bringChem
        let takeTheTrash = takeTrash
        let theNotes = notesTextView
        
        var weekStartDate : Date?
        var weekEndDate : Date?
        
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
            print(AddNewScheduleObjects.scheduledObject?.objectId)
        }
        
        ScheduleObject.registerSubclass()
        if sender as! NSObject == confirmButton {
            schObj.confirmedWith = self.confirmedWith.text!.capitalized
            schObj.confirmedDate = Date()
            schObj.confrimed = true
        }
        schObj.customerName = customerName!.capitalized
        schObj.customerAddress = addressLabel.text!.replacingOccurrences(of: "\n", with: " ").capitalized
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
        schObj.notes = theNotes?.text!
        if selectClosingDate.text != "Not Set" {
            schObj.confirmedDate = GlobalFunctions().dateFromShortDateString(selectClosingDate.text!)
            if PFUser.current()?.username != nil {
                schObj.confrimedBy = PFUser.current()?.username!.capitalized
            } else {
                do {
                    try PFUser.current()?.fetch()
                    schObj.confrimedBy = PFUser.current()?.username!.capitalized
                    
                } catch {
                    self.displayError("Error", message: "There was an error saving with the user infromation, please try again.")
                }
            }
            
            if schObj.smsEnabled != nil {
                if schObj.smsEnabled! {
                    // SMS Notify Enabled
                    if schObj.smsCustomerNotified != nil {
                        if schObj.smsCustomerNotified == false {
                            let smsNumber = (self.smsNumber.text?.components(separatedBy: CharacterSet.decimalDigits.inverted))!.joined(separator: "")
                            CloudCode.smsNotifyCustomer(smsNumber, dateSet: GlobalFunctions().dateFromShortDateString(selectClosingDate.text!), scheduleObject: schObj)
                            schObj.smsCustomerNotified = true
                        }
                    }
                }
            }
            
        } else {
            schObj.smsCustomerNotified = false
            schObj.confrimed = false
            schObj.remove(forKey: "confrimedBy")
            schObj.remove(forKey: "confirmedDate")
        }
        schObj.smsEnabled = self.smsSwitch.isOn
        if self.smsSwitch.isOn {
            schObj.smsNumber = (self.smsNumber.text?.components(separatedBy: CharacterSet.decimalDigits.inverted))!.joined(separator: "")
        }
        schObj.saveInBackground(block: { (success : Bool, error : Error?) in
            if success {
                if sender as! NSObject == self.generatePDFButton {
                    let sb = UIStoryboard(name: "OpeningPDFTemplate", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "PoolOpeningTemplate")
                    POCReportData.POCData = [schObj]
                    let view = vc.view
                    if let overlayView = self.view.viewWithTag(6969) {
                        overlayView.removeFromSuperview()
                    }
                    if let activityIndicator = self.view.viewWithTag(6868) {
                        activityIndicator.removeFromSuperview()
                    }
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
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyScheduleTableToRefresh"), object: nil)
                    AddNewScheduleObjects.isOpening = nil
                    if self.selectClosingDate.text != "Not Set" && sender as! NSObject == self.confirmButton {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyAppointmentConfirmed"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyScheduleTableToRefresh"), object: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        if customerNameTextField.text!.isEmpty || addressLabel.text!.isEmpty || phoneNumberTextField.text!.isEmpty || typeOfWinterCoverLabel.text!.isEmpty ||  locationEssentialItems.text.isEmpty {
            displayError("Missing Field", message: "There is a field missing, check your entries and try again")
        } else {
            if selectedWeekObj!.apptsRemain <= 0 {
                if self.managerOverrode || (PFUser.current()?.object(forKey: "isAdmin") as! Bool == true) {
                    if managerOverrode {
                        self.performSave(sender)
                    }
                    weekManagerOverride(sender)
                } else {
                    GlobalFunctions().requestOverride(overrideReason: "Overbooked Week", notificationName: Notification.string(name: "ManagerOverrideApproved"))
                }
            } else {
                self.performSave(sender)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        AddNewScheduleObjects.scheduledObject = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func segmentControl(_ selected : Int) -> String {
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
    
    func keyboardWillShow(_ notification : Notification) {
        
        var userInfo: [AnyHashable: Any] = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboard: CGRect = self.view.convert(keyboardFrame, from: self.view.window)
        let height: CGFloat = self.view.frame.size.height
        if ((keyboard.origin.y + keyboard.size.height) > height) {
            self.hasKeyboard = true
        }
        
        let toolbarHeight : CGFloat?
        
        if !notesTextView.isFirstResponder {
            return
        } else {
            
            if isKeyboardShowing == true {
                return
            } else {
                if let userInfo = (notification as NSNotification).userInfo {
                    if let keyboardSize = (userInfo [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                        if self.hasKeyboard == true && notesTextView.isFirstResponder {
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
    
    func keyboardWillHide(_ notification : Notification) {
        if (isKeyboardShowing != nil) {
            if isKeyboardShowing! {
                self.animateTextField(false)
                isKeyboardShowing = false
            }
        }
    }
    
    func animateTextField(_ up: Bool) {
        if kbHeight == nil {
            return
        } else {
            if customerNameTextField.isFirstResponder {
                
            } else {
                let movement = (up ? -kbHeight! : kbHeight!)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
                })
            }
        }
    }
    
    func weekPickerMakeAllOthersResign() {
        if !weekPicker.isFirstResponder {
            customerNameTextField.resignFirstResponder()
            addressLabel.resignFirstResponder()
            phoneNumberTextField.resignFirstResponder()
        }
    }
    
    var theWeekPickerHidden = true
    var theCoverTypePickerHidden = true
    
    let weekPickerIndexPath : IndexPath = IndexPath(item: 5, section: 0)
    let typePickerIndexPath : IndexPath = IndexPath(item: 8, section: 0)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if theWeekPickerHidden == false {
            weekPicker.isHidden = true
        } else {
            weekPicker.isHidden = false
        }
        
        if theCoverTypePickerHidden == false {
            typeOfWinterCoverPicker.isHidden = true
        } else {
            typeOfWinterCoverPicker.isHidden = false
        }
        
        if (indexPath as NSIndexPath).section  == 0 && (indexPath as NSIndexPath).row == 4 {
            toggleWeekPicker()
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 6 {
            toggleWeekPicker()
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 7 {
            toggleTypePicker()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 9 {
            if AddNewScheduleObjects.isOpening == nil {
                
            } else {
                if AddNewScheduleObjects.isOpening == true {
                    return 0
                }
            }
            
        }
        
        if AddNewScheduleObjects.scheduledObject == nil {
            if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
                return 0
            }
        }
        
        if theWeekPickerHidden == true && indexPath == weekPickerIndexPath {
            return 0
        }
        
        if theCoverTypePickerHidden == true && indexPath == typePickerIndexPath {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
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
    
    @IBAction func aquaDoorYesNo(_ sender: AnyObject) {
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
    
    @IBAction func bringChem(_ sender: AnyObject) {
        
        if bringCloseChemYesNo.selectedSegmentIndex == 0 {
            bringChem = true
        }
        
        if bringCloseChemYesNo.selectedSegmentIndex == 1 {
            bringChem = false
        }
        
    }
    
    @IBOutlet var takeTrashSeg: UISegmentedControl!
    var takeTrash : Bool = true
    
    @IBAction func takeTrash(_ sender: AnyObject) {
        
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
        
        let selectedCx = CustomerLookupObjects.slectedCustomer
        customerNameTextField.text = selectedCx!.firstName!.capitalized + " " + selectedCx!.lastName!.capitalized
        addressLabel.text = "\(selectedCx!.addressStreet.capitalized) \n \(selectedCx!.addressCity.capitalized), \(selectedCx!.addressState.uppercased()) \(selectedCx!.ZIP)"
        phoneNumberTextField.text = selectedCx?.phoneNumber
        self.accountNumber = selectedCx?.accountNumber
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
            
            var daysToAdd = 0.0
            
            repeat {
                let day : Double = 86400.0
                daysToAdd = daysToAdd + 1
                let addDate = startDate.addingTimeInterval(day * daysToAdd)
                dateWeekRange.append(GlobalFunctions().stringFromDateShortStyle(addDate))
            } while dateWeekRange.count < 7
            
            print(self.dateWeekRange)
            dateClosingPicker.reloadAllComponents()
            
        }
    }
    
    @IBAction func generatePDF(_ sender: AnyObject) {
        self.saveButton(sender)
    }
    
}
