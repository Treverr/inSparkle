//
//  AddEditWorkOderTableViewController.swift
//
//
//  Created by Trever on 2/22/16.
//
//

import UIKit
import Parse
import DropDown

class AddEditWorkOrderTableViewController: UITableViewController {
    
    @IBOutlet var customerNameTextField: UITextField!
    @IBOutlet var customerAddressTextField: UITextField!
    @IBOutlet var customerPhoneTextField: UITextField!
    @IBOutlet var customerAltPhoneTextField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var wtbpTextView: UITextView!
    @IBOutlet var descOfWork: UITextView!
    @IBOutlet var unitMake: UITextField!
    @IBOutlet var unitModel: UITextField!
    @IBOutlet var unitSerial: UITextField!
    @IBOutlet var managePartsLabel: UILabel!
    @IBOutlet var manageLaborLabel: UILabel!
    @IBOutlet var tripOneDateTimeArriveLabel: UILabel!
    @IBOutlet var tripOneDateTimeDepartLabel: UILabel!
    @IBOutlet var tripTwoDateTimeArriveLabel: UILabel!
    @IBOutlet var tripTwoDateTimeDepartLabel: UILabel!
    @IBOutlet var techLabel: UILabel!
    @IBOutlet var reccomendationTextView: UITextView!
    @IBOutlet var techCell: UITableViewCell!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusCell: UITableViewCell!
    
    var parts : [String]!
    var labor : [String]!
    var techDataSource = [String]()
    var techDict = [String : Employee]()
    var selectedTech : Employee?
    
    var workOrderObject : WorkOrders?
    
    let dropDownTech = DropDown()
    
    @IBOutlet var wordOrderDatePicker: UIDatePicker!
    @IBOutlet var tripOneArrivePicker: UIDatePicker!
    @IBOutlet var tripOneDepartPicker: UIDatePicker!
    @IBOutlet var tripTwoArrivePicker: UIDatePicker!
    @IBOutlet var tripTwoDepartPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTechs()
        
        statusLabel.text = "New"
        
        if workOrderObject != nil {
            displayExistingWorkOrder()
            self.navigationItem.title = "Edit Work Order"
        } else  {
            workOrderDatePickerChanged()
        }
        
        if parts != nil {
            if parts.count != 0 {
                
            }
        }
        
        wordOrderDatePicker.hidden = true
        tripOneArrivePicker.hidden = true
        tripOneDepartPicker.hidden = true
        tripTwoArrivePicker.hidden = true
        tripTwoDepartPicker.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("UpdateCustomerFields"), name: "UpdateFieldsOnAddEditWorkOrder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("UpdatePartsArray:"), name: "UpdatePartsArray", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("UpdateLaborArray:"), name: "UpdateLaborArray", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateStatusLabel:"), name: "updateStatusLabel", object: nil)
        
        setUpDropDownTech()
        
    }
    
    func getTechs() {
        let techs = Employee.query()
        techs?.whereKey("active", equalTo: true)
        techs?.orderByAscending("firstName")
        techs?.findObjectsInBackgroundWithBlock({ (techs : [PFObject]?, error : NSError?) in
            if error == nil {
                let theTechs = techs as! [Employee]
                for tech in theTechs {
                    self.techDict[tech.firstName + " " + tech.lastName] = tech
                }
                print(self.techDict)
                var techList : [String] {
                    get {
                        return Array(self.techDict.keys)
                    }
                }
                print(techList)
                var sorted = GlobalFunctions().qsort(techList)
                print(techList)
                self.techDataSource = sorted
                self.dropDownTech.dataSource = self.techDataSource
            }
        })
    }
    
    func setUpDropDownTech() {
        dropDownTech.anchorView = techCell
        dropDownTech.direction = .Any
        dropDownTech.bottomOffset = CGPoint(x: 0, y: dropDownTech.anchorView!.bounds.height)
        dropDownTech.topOffset = CGPoint(x: 0, y: -dropDownTech.anchorView!.bounds.height)
        dropDownTech.dismissMode = .Automatic
        dropDownTech.selectionAction = { [unowned self] (index, item) in
            self.techLabel.text = item
            self.techLabel.textColor = UIColor.blackColor()
            self.selectedTech = self.techDict[item]
            print(self.selectedTech!)
        }
    }
    
    func updateStatusLabel(notification : NSNotification) {
        let status = notification.object as! String
        statusLabel.text = status
        switch notification.object as! String {
        case "New":
            statusCell.imageView?.image = UIImage(named: "WO New")
        case "In Progress":
            statusCell.imageView?.image = UIImage(named: "WO In Progress")
        case "On Hold":
            statusCell.imageView?.image = UIImage(named: "WO On Hold")
        case "Assigned":
            statusCell.imageView?.image = UIImage(named: "WO Assinged")
        case "Completed":
            statusCell.imageView?.image = UIImage(named: "WO Completed")
        case "Billed":
            statusCell.imageView?.image = UIImage(named: "WO Billed")
        default:
            statusCell.imageView?.image = nil
        }
    }
    
    func displayExistingWorkOrder() {
        if workOrderObject?.customerName != nil {
            customerNameTextField.text = workOrderObject!.customerName
        }
        if workOrderObject?.customerAddress != nil {
            customerAddressTextField.text = workOrderObject!.customerAddress
        }
        if workOrderObject?.customerPhone != nil {
            customerPhoneTextField.text = workOrderObject!.customerPhone
        }
        if workOrderObject?.customerAltPhone != nil {
            customerAltPhoneTextField.text = workOrderObject!.customerAltPhone
        }
        if workOrderObject?.date != nil {
            dateLabel.text = GlobalFunctions().stringFromDateShortStyle(workOrderObject!.date)
            dateLabel.textColor = UIColor.blackColor()
        }
        if workOrderObject?.technician != nil {
            techLabel.text = workOrderObject!.technician!
            techLabel.textColor = UIColor.blackColor()
        }
        if workOrderObject?.workToBePerformed != nil {
            wtbpTextView.text = workOrderObject!.workToBePerformed
        }
        if workOrderObject?.descOfWork != nil {
            descOfWork.text = workOrderObject!.descOfWork
        }
        if workOrderObject?.reccomendation != nil {
            reccomendationTextView.text = workOrderObject!.reccomendation
        }
        if workOrderObject?.unitMake != nil {
            unitMake.text = workOrderObject!.unitMake
        }
        if workOrderObject?.unitModel != nil {
            unitModel.text = workOrderObject!.unitModel
        }
        if workOrderObject?.unitSerial != nil {
            unitSerial.text = workOrderObject!.unitSerial
        }
        if workOrderObject?.parts != nil {
            self.parts = workOrderObject!.parts as! [String]
            if parts.count != 0 {
                managePartsLabel.text = "Manage Parts (\(self.parts.count))"
            }
        }
        if workOrderObject?.status != nil {
            statusLabel.text = workOrderObject?.status
            switch workOrderObject!.status! {
            case "New":
                statusCell.imageView?.image = UIImage(named: "WO New")
            case "In Progress":
                statusCell.imageView?.image = UIImage(named: "WO In Progress")
            case "On Hold":
                statusCell.imageView?.image = UIImage(named: "WO On Hold")
            case "Assigned":
                statusCell.imageView?.image = UIImage(named: "WO Assinged")
            case "Completed":
                statusCell.imageView?.image = UIImage(named: "WO Completed")
            case "Billed":
                statusCell.imageView?.image = UIImage(named: "WO Billed")
            default:
                statusCell.imageView?.image = nil
            }
        }
        if workOrderObject?.labor != nil {
            self.labor = workOrderObject!.labor as! [String]
            if labor.count != 0 {
                manageLaborLabel.text = "Manage Labor (\(self.labor.count))"
            }
        }
        if workOrderObject?.tripOneArrive != nil {
            tripOneDateTimeArriveLabel.textColor = UIColor.blackColor()
            tripOneDateTimeArriveLabel.text = GlobalFunctions().stringFromDateShortTimeShortDate(workOrderObject!.tripOneArrive!)
        }
        if workOrderObject?.tripOneDepart != nil {
            tripOneDateTimeDepartLabel.textColor = UIColor.blackColor()
            tripOneDateTimeDepartLabel.text = GlobalFunctions().stringFromDateShortTimeShortDate(workOrderObject!.tripOneDepart!)
        }
        if workOrderObject?.tripTwoArrive != nil {
            tripTwoDateTimeArriveLabel.textColor = UIColor.blackColor()
            tripTwoDateTimeArriveLabel.text = GlobalFunctions().stringFromDateShortTimeShortDate(workOrderObject!.tripTwoArrive!)
        }
        if workOrderObject?.tripTwoDepart != nil {
            tripTwoDateTimeDepartLabel.textColor = UIColor.blackColor()
            tripTwoDateTimeDepartLabel.text = GlobalFunctions().stringFromDateShortTimeShortDate(workOrderObject!.tripTwoDepart!)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "customerLookup" {
            CustomerLookupObjects.fromVC = "AddEditWorkOrder"
        }
        if segue.identifier == "parts" {
            let dest = segue.destinationViewController as! WorkOrderPartsTableViewController
            if parts != nil {
                if parts.count != 0 {
                    dest.parts = self.parts
                }
            }
        }
        if segue.identifier == "labor" {
            let dest = segue.destinationViewController as! LaborPartsTableViewController
            if self.labor != nil {
                if self.labor.count != 0 {
                    dest.labor = self.labor
                }
            }
        }
    }
    
    func UpdatePartsArray(notification : NSNotification) {
        self.parts = notification.object as! [String]
        if parts.count != 0 {
            managePartsLabel.text = "Manage Parts (\(self.parts.count))"
        }
        if parts.count == 0 {
            managePartsLabel.text = "Manage Labor"
        }
    }
    
    func UpdateLaborArray(notification : NSNotification) {
        self.labor = notification.object as! [String]
        print(notification.object)
        if labor.count != 0 {
            manageLaborLabel.text = "Manage Labor (\(self.labor.count))"
        }
        if labor.count == 0 {
            manageLaborLabel.text = "Manage Labor"
        }
    }
    
    func UpdateCustomerFields() {
        let selectCx = CustomerLookupObjects.slectedCustomer
        
        customerNameTextField.text = selectCx!.firstName!.capitalizedString + " " + selectCx!.lastName!.capitalizedString
        customerPhoneTextField.text = selectCx!.phoneNumber
        customerAddressTextField.text = "\(selectCx!.addressStreet.capitalizedString) \(selectCx!.addressCity.capitalizedString), \(selectCx!.addressState) \(selectCx!.ZIP)"
    }
    
    func workOrderDatePickerChanged() {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(wordOrderDatePicker.date, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        
    }
    
    func tripOneArrivePickerChanged() {
        tripOneDateTimeArriveLabel.text = NSDateFormatter.localizedStringFromDate(tripOneArrivePicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        
    }
    
    func tripOneDepartPickerChanged() {
        tripOneDateTimeDepartLabel.text = NSDateFormatter.localizedStringFromDate(tripOneDepartPicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    
    func tripTwoArrivePickerChanged() {
        tripTwoDateTimeArriveLabel.text = NSDateFormatter.localizedStringFromDate(tripTwoArrivePicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    
    func tripTwoDepartPickerChanged(){
        tripTwoDateTimeDepartLabel.text = NSDateFormatter.localizedStringFromDate(tripTwoDepartPicker.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if cell?.reuseIdentifier == "datePromised" {
            toggleDatePromisedPicker()
        }
        
        if cell?.reuseIdentifier == "tripOneArrive" {
            toggleTripOneArrivePicker()
        }
        
        if cell?.reuseIdentifier == "tripOneDepart" {
            toggleTripOneDepartPicker()
        }
        
        if cell?.reuseIdentifier == "tripTwoArrive" {
            toggleTripTwoArrivePicker()
        }
        
        if cell?.reuseIdentifier == "tripTwoDepart" {
            toggleTripTwoDepartPicker()
        }
        
        if cell?.reuseIdentifier == "techCell" {
            dropDownTech.show()
        }
        
    }
    
    var datePromisedPickerHidden = true
    var tripOneArrivePickerHidden = true
    var tripOneDapartPickerHidden = true
    var tripTwoArrivePickerHidden = true
    var tripTwoDepartPickerHidden = true
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let datePromisedIndex = NSIndexPath(forRow: 1, inSection: 1)
        let tripOneArriveIndex = NSIndexPath(forRow: 1, inSection: 5)
        let tripOneDepartIndex = NSIndexPath(forRow: 3, inSection: 5)
        let tripTwoArriveIndex = NSIndexPath(forRow: 1, inSection: 6)
        let tripTwoDepartIndex = NSIndexPath(forRow: 3, inSection: 6)
        
        if datePromisedPickerHidden && (indexPath == datePromisedIndex){
            return 0
        }
        
        if tripOneDapartPickerHidden && (indexPath == tripOneDepartIndex) {
            return 0
        }
        
        if tripTwoArrivePickerHidden && (indexPath == tripTwoArriveIndex) {
            return 0
        }
        
        if tripTwoDepartPickerHidden && (indexPath == tripTwoDepartIndex) {
            return 0
        }
        
        if tripOneArrivePickerHidden && (indexPath == tripOneArriveIndex) {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    func toggleDatePromisedPicker() {
        datePromisedPickerHidden = !datePromisedPickerHidden
        
        if wordOrderDatePicker.hidden {
            wordOrderDatePicker.hidden = false
        } else {
            wordOrderDatePicker.hidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleTripOneArrivePicker() {
        tripOneArrivePickerHidden = !tripOneArrivePickerHidden
        
        if tripOneArrivePicker.hidden {
            tripOneArrivePicker.hidden = false
        } else {
            tripOneArrivePicker.hidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func toggleTripOneDepartPicker() {
        tripOneDapartPickerHidden = !tripOneDapartPickerHidden
        
        if tripOneDepartPicker.hidden {
            tripOneDepartPicker.hidden = false
        } else {
            tripOneDepartPicker.hidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func toggleTripTwoArrivePicker() {
        tripTwoArrivePickerHidden = !tripTwoArrivePickerHidden
        
        if tripTwoArrivePicker.hidden {
            tripTwoArrivePicker.hidden = false
        } else {
            tripTwoArrivePicker.hidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableViewScrollToBottom(true)
    }
    
    func toggleTripTwoDepartPicker() {
        tripTwoDepartPickerHidden = !tripTwoDepartPickerHidden
        
        if tripTwoDepartPicker.hidden {
            tripTwoDepartPicker.hidden = false
        } else {
            tripTwoDepartPicker.hidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableViewScrollToBottom(true)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    @IBAction func datePromisedPickerAction(sender: AnyObject) {
        tripOneArrivePicker.minimumDate = wordOrderDatePicker.date
        tripTwoArrivePicker.minimumDate = wordOrderDatePicker.date
        dateLabel.textColor = UIColor.blackColor()
        workOrderDatePickerChanged()
    }
    
    @IBAction func tripOneArrivePickerAction(sender: AnyObject) {
        tripOneDepartPicker.minimumDate = tripOneArrivePicker.date
        tripOneDateTimeArriveLabel.textColor = UIColor.blackColor()
        tripOneArrivePickerChanged()
    }
    
    @IBAction func tripOneDepatPickerAction(sender : AnyObject) {
        tripOneDateTimeDepartLabel.textColor = UIColor.blackColor()
        tripOneDepartPickerChanged()
    }
    
    @IBAction func tripTwoArrivePickerAction(sender: AnyObject) {
        tripTwoDepartPicker.minimumDate = tripTwoArrivePicker.date
        tripTwoDateTimeArriveLabel.textColor = UIColor.blackColor()
        tripTwoArrivePickerChanged()
    }
    
    @IBAction func tripTwoDepartPickerAction(sender: AnyObject) {
        tripTwoDateTimeDepartLabel.textColor = UIColor.blackColor()
        tripTwoDepartPickerChanged()
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if customerNameTextField.text!.isEmpty || customerAddressTextField.text!.isEmpty || customerPhoneTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Customer Data", message: "There seems to be required data missing from the customer infromation, please check and try again.", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okButton)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            if workOrderObject == nil {
                workOrderObject = WorkOrders()
            }
            workOrderObject?.customerName = customerNameTextField.text
            workOrderObject?.customerAddress = customerAddressTextField.text
            workOrderObject?.customerPhone = customerPhoneTextField.text
            if customerAltPhoneTextField.text!.isEmpty == false {
                workOrderObject?.customerAltPhone = customerAltPhoneTextField.text
            }
            workOrderObject?.date = GlobalFunctions().dateFromShortDateString(dateLabel.text!)
            if techLabel.text != "name" {
                workOrderObject?.technician = techLabel.text
            }
            if wtbpTextView.text.isEmpty == false {
                workOrderObject?.workToBePerformed = wtbpTextView.text
            }
            if descOfWork.text.isEmpty == false {
                workOrderObject?.descOfWork = descOfWork.text
            }
            if reccomendationTextView.text.isEmpty == false {
                workOrderObject?.reccomendation = reccomendationTextView.text
            }
            if unitMake.text?.isEmpty == false {
                workOrderObject?.unitMake = unitMake.text
            }
            if unitModel.text?.isEmpty == false {
                workOrderObject?.unitModel = unitModel.text
            }
            if unitSerial.text?.isEmpty == false {
                workOrderObject?.unitSerial = unitSerial.text
            }
            if self.parts != nil {
                if self.parts.count == 0 {
                    workOrderObject?.parts = []
                } else {
                    workOrderObject?.parts = self.parts
                }
            }
            if self.labor != nil {
                if self.labor.count == 0 {
                    workOrderObject?.labor? = []
                } else {
                    workOrderObject?.labor = self.labor
                }
            }
            if tripOneDateTimeArriveLabel.text != "date & time" {
                workOrderObject?.tripOneArrive = GlobalFunctions().dateFromShortDateShortTime(tripOneDateTimeArriveLabel.text!)
            }
            if tripOneDateTimeDepartLabel.text != "date & time" {
                workOrderObject?.tripOneDepart = GlobalFunctions().dateFromShortDateShortTime(tripOneDateTimeDepartLabel.text!)
            }
            if tripTwoDateTimeArriveLabel.text != "date & time" {
                workOrderObject?.tripTwoArrive = GlobalFunctions().dateFromShortDateShortTime(tripTwoDateTimeArriveLabel.text!)
            }
            if tripTwoDateTimeDepartLabel.text != "date & time" {
                workOrderObject?.tripTwoDepart = GlobalFunctions().dateFromShortDateShortTime(tripTwoDateTimeDepartLabel.text!)
            }
            workOrderObject?.status = statusLabel.text
            print(workOrderObject)
            workOrderObject?.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                if success == true {
                    let successAlert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .Alert)
                    self.presentViewController(successAlert, animated: true, completion: {
                        let delay = 1.0 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        
                        dispatch_after(time, dispatch_get_main_queue(), {
                            self.dismissViewControllerAnimated(true, completion: {
                                self.performSegueWithIdentifier("unwindToWOMain", sender: nil)
                            })
                        })
                    })
                }
                if error != nil {
                    let errorAlert = UIAlertController(title: "Error", message: "There was an error attempting to save the work order, please try again.", preferredStyle: .Alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    errorAlert.addAction(okayButton)
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func generatePDF(sender: AnyObject) {
        let sb = UIStoryboard(name: "WorkOrderPDFTemplate", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("workOrderPDF") as! WorkOrderPDFTemplateViewController
        vc.workOrderObject = self.workOrderObject
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
}

extension AddEditWorkOrderTableViewController : UITextViewDelegate {
    
}

extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}
