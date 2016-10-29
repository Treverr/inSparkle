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
    var categories = ["Liners",
                      "Hearth",
                      "Pool Kits",
                      "Electric Covers",
                      "Winter Covers",
                      "Pumps/Motors",
                      "Heaters",
                      "Misc"]
    
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
            
            customerNameTextField.text = existingObject!.value(forKey: "customerName") as! String
            if (existingObject!.value(forKey: "date") != nil) {
                let date = existingObject!.value(forKey: "date") as! Date
                dateLabel.text = GlobalFunctions().stringFromDateShortStyle(date)
                
            }
            locationLabel.text = existingObject!.value(forKey: "location") as! String
            locationLabel.textColor = UIColor.black
            categoryLabel.text = existingObject!.value(forKey: "category") as! String
            if (existingObject!.value(forKey: "serial")) != nil {
                barcodeTextField.text = existingObject!.value(forKey: "serial") as! String
            }
            if existingObject?.value(forKey: "orderNumber") != nil {
                orderNumber.text = existingObject?.value(forKey: "orderNumber") as! String
            }
            tableView.isScrollEnabled = true
        } else {
            tableView.isScrollEnabled = false
        }
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        
        if (DataManager.isEditingSOIbject!) {
            locationLabel.textColor = UIColor.black
            if existingObject?.value(forKey: "date") != nil {
                dateLabel.textColor = UIColor.black
            }
            categoryLabel.textColor = UIColor.black
        } else {
            locationLabel.textColor = Colors.placeholderGray
            dateLabel.textColor = Colors.placeholderGray
            categoryLabel.textColor = Colors.placeholderGray
        }
        
        
        locationPicker.dataSource = self
        locationPicker.delegate = self
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewSOITableViewController.setTheBarcode(_:)), name: NSNotification.Name(rawValue: "barcodeNotification"), object: nil)
        
        // Set all the textfield delegates
        customerNameTextField.delegate = self
        barcodeTextField.delegate = self
        
        locationPicker.tag = 0
        categoryPicker.tag = 1
        datePicker.tag = 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLocationsFromParse()
    }
    
    func setTheBarcode(_ barcode : Notification) {
        let theBarcode = barcode.object as! String
        print(theBarcode)
        DispatchQueue.main.async { [unowned self] in
            self.barcodeTextField.text = theBarcode
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var count : Int?
        
        if pickerView.tag == 0 {
            count = locationsArray.count
        }
        
        if pickerView.tag == 1 {
            count = categories.count
        }
        
        return count!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var title_ : String?
        
        if pickerView.tag == 0 {
            title_ = locationsArray[row]
        }
        
        if pickerView.tag == 1 {
            title_ = categories[row]
        }
        
        return title_
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            locationLabel.textColor = UIColor.black
            locationLabel.text = locationsArray[row]
        }
        
        if pickerView.tag == 1 {
            categoryLabel.textColor = UIColor.black
            categoryLabel.text = categories[row]
        }
        
    }
    
    
    @IBAction func cancelButtonAction(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonAction(_ sender: AnyObject) {
        
        print("Save Button")
        
        let customerName = customerNameTextField.text
        print(customerName)
        let date_ = dateLabel.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let sendDate : Date? = formatter.date(from: date_!)
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
                    existingObject?.remove(forKey: "orderNumber")
                }
                existingObject?.saveEventually({ (success : Bool, error: Error?) -> Void in
                    if error == nil {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshSOINotification"), object: nil)
                        self.dismiss(animated: true, completion: nil)
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
                soiObject["enteredBy"] = PFUser.current()
                soiObject.saveEventually({ (success : Bool, error: Error?) -> Void in
                    if error == nil {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshSOINotification"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print(error)
                    }
                })
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DataManager.isEditingSOIbject = false
    }
    
    func datePickerChanged () {
        dateLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        dateLabel.textColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if datePickerHidden == false {
            datePicker.isHidden = true
        } else {
            datePicker.isHidden = false
        }
        
        if locationPickerHidden == false {
            locationPicker.isHidden = true
        } else {
            locationPicker.isHidden = false
        }
        
        if categoryPickerHidden == false {
            categoryPicker.isHidden = true
        } else {
            categoryPicker.isHidden = false
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 3 {
            toggleDatepicker()
            datePickerChanged()
            
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 5 {
            toggleLocationPicker()
            if locationLabel.text == "required" || locationLabel.text == "" {
                locationLabel.text = locationsArray[0]
                locationLabel.textColor = UIColor.black
            }
            
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            toggleCategoryPicker()
            if categoryLabel.text == "required" || categoryLabel.text == "" {
                categoryLabel.text = categories[0]
                categoryLabel.textColor = UIColor.black
            }
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 7 {
            
            locationPickerHidden = true
            datePickerHidden = true
            categoryPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
            locationPickerHidden = true
            datePickerHidden = true
            categoryPickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        customerNameTextField.resignFirstResponder()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if datePickerHidden && (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 4 {
            return 0
        }
        
        if categoryPickerHidden && (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            return 0
        }
        
        if locationPickerHidden && (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 6 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    @IBAction func barcodeButton(_ sender: AnyObject) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let scanVC = storyBoard.instantiateViewController(withIdentifier: "BarcodeScannerNav")
        
        self.present(scanVC, animated: true, completion: nil)
        
        
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
    
    
    @IBAction func datePickerAction(_ sender: AnyObject) {
        
        datePickerChanged()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        locationPickerHidden = true
        locationPicker.isHidden = true
        categoryPickerHidden = true
        categoryPicker.isHidden = true
        datePickerHidden = true
        datePicker.isHidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func getLocationsFromParse() {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let filePath = documents + "/locationList.plist"
        
        let savedLocationArray : [String]?
        
        if checkForLocationFile(filePath) {
            savedLocationArray = grabLocationsFile(filePath)
            self.locationsArray = savedLocationArray!
        } else {
            savedLocationArray = []
        }
        
        
        let locationQuery = PFQuery(className: "locationList")
        locationQuery.findObjectsInBackground { (locations: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                let locationCount = locations!.count
                var possibleLocationsArray : [String] = []
                for location in locations! {
                    
                    if (locationCount - possibleLocationsArray.count) != 0 {
                        possibleLocationsArray.append(location.value(forKey: "locationName") as! String)
                        print("Added to array")
                    }
                    
                    if (locationCount - possibleLocationsArray.count) == 0 {
                        
                        if possibleLocationsArray == savedLocationArray! {
                            print("Nothing Changed")
                        } else {
                            print("Updating Local File")
                            self.locationsArray = possibleLocationsArray
                            let arrayToSave = self.locationsArray as NSArray
                            arrayToSave.write(toFile: filePath, atomically: true)
                        }
                    }
                    
                }
            } else {
                print("Network error, using saved")
            }
        }
    }
    
    func displaySaveError() {
        let alert = UIAlertController(title: nil, message: "Check the fields, it looks like at least one is missing.", preferredStyle: .alert)
        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkForLocationFile(_ filePath : String) -> Bool {
        let fileManager = FileManager.default
        
        if (fileManager.fileExists(atPath: filePath)) {
            print("FILE AVAILABLE")
            return true
        } else {
            print("FILE NOT AVAILABLE")
            return false
        }
    }
    
    func grabLocationsFile(_ filePath : String) -> [String] {
        var returnArray : [String]?
        
        let array = NSArray(contentsOfFile: filePath)
        
        returnArray = array! as! [String]
        
        print(returnArray)
        
        
        return returnArray!
    }
    
}
