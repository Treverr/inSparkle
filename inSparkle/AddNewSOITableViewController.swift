//
//  AddNewSOITableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/13/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class AddNewSOITableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var customerNameTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet var orderNumber: UITextField!
    
    @IBOutlet weak var barcodeTextField: UITextField!
    
    var existingObject : PFObject?
    
    
    var barcodeReturned : String?
    
    var locationsArray : [String] = []
    var categories = ["Liners", "Hearth", "Pool Kits", "Electric Covers", "Winter Covers", "Pumps/Motors", "Misc"]
    
    var datePickerHidden = true
    var locationPickerHidden = true
    var categoryPickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataManager.isEditingSOIbject == nil {
            DataManager.isEditingSOIbject = false
        }
        
        if (DataManager.isEditingSOIbject!) {
            existingObject = DataManager.passingObject!
            
            customerNameTextField.text = existingObject!.valueForKey("customerName") as! String
            if (existingObject!.valueForKey("date") != nil) {
                let date = existingObject!.valueForKey("date") as! NSDate
                dateLabel.text = GlobalFunctions().stringFromDateShortStyle(date)
                
            }
            locationLabel.text = existingObject!.valueForKey("location") as! String
            locationLabel.textColor = UIColor.blackColor()
            categoryLabel.text = existingObject!.valueForKey("category") as! String
            if (existingObject!.valueForKey("serial")) != nil {
                barcodeTextField.text = existingObject!.valueForKey("serial") as! String
            }
            if existingObject?.valueForKey("orderNumber") != nil {
                orderNumber.text = existingObject?.valueForKey("orderNumber") as! String
            }
            tableView.scrollEnabled = true
        } else {
            tableView.scrollEnabled = false
        }
        
        setupNavigationbar()
        
        
        if (DataManager.isEditingSOIbject!) {
            locationLabel.textColor = UIColor.blackColor()
            if existingObject?.valueForKey("date") != nil {
                dateLabel.textColor = UIColor.blackColor()
            }
            categoryLabel.textColor = UIColor.blackColor()
        } else {
            locationLabel.textColor = Colors.placeholderGray
            dateLabel.textColor = Colors.placeholderGray
            categoryLabel.textColor = Colors.placeholderGray
        }
        
        
        locationPicker.dataSource = self
        locationPicker.delegate = self
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTheBarcode:", name: "barcodeNotification", object: nil)
        
        // Set all the textfield delegates
        customerNameTextField.delegate = self
        barcodeTextField.delegate = self
        
        locationPicker.tag = 0
        categoryPicker.tag = 1
        datePicker.tag = 2
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getLocationsFromParse()
    }
    
    func setTheBarcode(barcode : NSNotification) {
        let theBarcode = barcode.object as! String
        print(theBarcode)
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.barcodeTextField.text = theBarcode
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var count : Int?
        
        if pickerView.tag == 0 {
            count = locationsArray.count
        }
        
        if pickerView.tag == 1 {
            count = categories.count
        }
        
        return count!
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title_ : String?
        
        if pickerView.tag == 0 {
            title_ = locationsArray[row]
        }
        
        if pickerView.tag == 1 {
            title_ = categories[row]
        }
        
        return title_
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            locationLabel.textColor = UIColor.blackColor()
            locationLabel.text = locationsArray[row]
        }
        
        if pickerView.tag == 1 {
            categoryLabel.textColor = UIColor.blackColor()
            categoryLabel.text = categories[row]
        }
        
    }
    
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func saveButtonAction(sender: AnyObject) {
        
        print("Save Button")
        
        let customerName = customerNameTextField.text
        print(customerName)
        let date_ = dateLabel.text
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let sendDate : NSDate? = formatter.dateFromString(date_!)
        print(sendDate)
        
        let location = locationLabel.text
        print(location)
        let serial = barcodeTextField.text
        print(serial)
        let category = categoryLabel.text
        print(category)
        
        let soiObject : PFObject = PFObject(className: "SOI")
        
        if customerName == "" || category == "required" || location == "required" {
            displaySaveError()
        } else {
            if (DataManager.isEditingSOIbject!) {
                existingObject?.setValue(customerName!, forKey: "customerName")
                if sendDate != nil {
                    existingObject?.setValue(sendDate!, forKey: "date")
                }
                if serial != nil {
                    existingObject?.setValue(serial!, forKey: "serial")
                }
                existingObject?.setValue(category!, forKey: "category")
                existingObject?.setValue(true, forKey: "isActive")
                existingObject?.setValue(location!, forKey: "location")
                if !orderNumber.text!.isEmpty {
                    existingObject?.setValue(orderNumber.text!, forKey: "orderNumber")
                } else {
                    existingObject?.removeObjectForKey("orderNumber")
                }
                existingObject?.saveEventually({ (success : Bool, error: NSError?) -> Void in
                    if error == nil {
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshSOINotification", object: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print(error)
                    }
                })
            } else {
                soiObject["customerName"] = customerName!
                if sendDate != nil {
                    soiObject["date"] = sendDate
                }
                soiObject["location"] = location!
                if serial != "" {
                    soiObject["serial"] = serial
                }
                soiObject["category"] = category
                soiObject["isActive"] = true
                if !orderNumber.text!.isEmpty {
                    soiObject["orderNumber"] = orderNumber.text!
                }
                soiObject["enteredBy"] = PFUser.currentUser()
                soiObject.saveEventually({ (success : Bool, error: NSError?) -> Void in
                    if error == nil {
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshSOINotification", object: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print(error)
                    }
                })
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        DataManager.isEditingSOIbject = false
    }
    
    func datePickerChanged () {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(datePicker.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        dateLabel.textColor = UIColor.blackColor()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if datePickerHidden == false {
            datePicker.hidden = true
        } else {
            datePicker.hidden = false
        }
        
        if locationPickerHidden == false {
            locationPicker.hidden = true
        } else {
            locationPicker.hidden = false
        }
        
        if categoryPickerHidden == false {
            categoryPicker.hidden = true
        } else {
            categoryPicker.hidden = false
        }
        
        if indexPath.section == 0 && indexPath.row == 3 {
            toggleDatepicker()
            
        }
        
        if indexPath.section == 0 && indexPath.row == 5 {
            toggleLocationPicker()
            if locationLabel.text == "required" || locationLabel.text == "" {
                locationLabel.text = locationsArray[0]
                locationLabel.textColor = UIColor.blackColor()
            }
            
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            toggleCategoryPicker()
            if categoryLabel.text == "required" || categoryLabel.text == "" {
                categoryLabel.text = categories[0]
                categoryLabel.textColor = UIColor.blackColor()
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 7 {
            
            locationPickerHidden = true
            datePickerHidden = true
            categoryPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            locationPickerHidden = true
            datePickerHidden = true
            categoryPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        customerNameTextField.resignFirstResponder()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if datePickerHidden && indexPath.section == 0 && indexPath.row == 4 {
            return 0
        }
        
        if categoryPickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        }
        
        if locationPickerHidden && indexPath.section == 0 && indexPath.row == 6 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    @IBAction func barcodeButton(sender: AnyObject) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let scanVC = storyBoard.instantiateViewControllerWithIdentifier("BarcodeScannerNav")
        
        self.presentViewController(scanVC, animated: true, completion: nil)
        
        
    }
    
    
    func toggleDatepicker() {
        
        datePickerHidden = !datePickerHidden
        locationPickerHidden = true
        categoryPickerHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func toggleLocationPicker() {
        locationPickerHidden = !locationPickerHidden
        datePickerHidden = true
        categoryPickerHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleCategoryPicker() {
        categoryPickerHidden = !categoryPickerHidden
        datePickerHidden = true
        locationPickerHidden = true
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func datePickerAction(sender: AnyObject) {
        
        datePickerChanged()
        
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        locationPickerHidden = true
        locationPicker.hidden = true
        categoryPickerHidden = true
        categoryPicker.hidden = true
        datePickerHidden = true
        datePicker.hidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func getLocationsFromParse() {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let filePath = documents.stringByAppendingString("/locationList.plist")
        
        let savedLocationArray : [String]?
        
        if checkForLocationFile(filePath) {
            savedLocationArray = grabLocationsFile(filePath)
            self.locationsArray = savedLocationArray!
        } else {
            savedLocationArray = []
        }
        
        
        let locationQuery = PFQuery(className: "locationList")
        locationQuery.findObjectsInBackgroundWithBlock { (locations: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                var locationCount = locations!.count
                var possibleLocationsArray : [String] = []
                for location in locations! {
                    
                    if (locationCount - possibleLocationsArray.count) != 0 {
                        possibleLocationsArray.append(location.valueForKey("locationName") as! String)
                        print("Added to array")
                    }
                    
                    if (locationCount - possibleLocationsArray.count) == 0 {
                        
                        if possibleLocationsArray == savedLocationArray! {
                            print("Nothing Changed")
                        } else {
                            print("Updating Local File")
                            self.locationsArray = possibleLocationsArray
                            let arrayToSave = self.locationsArray as NSArray
                            arrayToSave.writeToFile(filePath, atomically: true)
                        }
                    }
                    
                }
            } else {
                print("Network error, using saved")
            }
        }
    }
    
    func displaySaveError() {
        let alert = UIAlertView()
        alert.message = "Check the fields, it looks like at least one is missing."
        alert.addButtonWithTitle("Okay")
        alert.show()
    }
    
    func checkForLocationFile(filePath : String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(filePath)) {
            print("FILE AVAILABLE")
            return true
        } else {
            print("FILE NOT AVAILABLE")
            return false
        }
    }
    
    func grabLocationsFile(filePath : String) -> [String] {
        var returnArray : [String]?
        
        let array = NSArray(contentsOfFile: filePath)
        
        returnArray = array! as! [String]
        
        print(returnArray)
        
        
        return returnArray!
    }
    
}
