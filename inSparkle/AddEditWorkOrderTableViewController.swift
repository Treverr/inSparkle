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

class AddEditWorkOrderTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
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
    @IBOutlet var techLabel: UILabel!
    @IBOutlet var techCell: UITableViewCell!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusCell: UITableViewCell!
    
    var parts : [String]!
    var labor : [String]!
    var techDataSource = [String]()
    var techDict = [String : Employee]()
    var selectedTech : Employee?
    
    var workOrderObject : WorkOrders?
    
    @IBOutlet var wordOrderDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTechs()
        
        statusLabel.text = "New"
        
        if workOrderObject != nil {
            displayExistingWorkOrder()
            self.navigationItem.title = "Edit Work Order"
            getMTNotes()
        } else  {
            workOrderDatePickerChanged()
        }
        
        if parts != nil {
            if parts.count != 0 {
                
            }
        }
        
        wordOrderDatePicker.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdateCustomerFields), name: "UpdateFieldsOnAddEditWorkOrder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdatePartsArray(_:)), name: "UpdatePartsArray", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdateLaborArray(_:)), name: "UpdateLaborArray", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.updateStatusLabel(_:)), name: "updateStatusLabel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.updateTechLabel(_:)), name: "updateTechLabel", object: nil)
        
        
    }
    
    func getMTNotes() {
        let query = PFQuery(className: "MobileTechServiceObjectNotes")
        query.whereKey("relatedWorkOder", equalTo: self.workOrderObject!)
        query.findObjectsInBackgroundWithBlock { (notes : [PFObject]?, error : NSError?) in
            if error == nil {
                for note in notes! {
                    if note == notes?.last {
                        self.descOfWork.text! += note.objectForKey("noteContent") as! String
                    } else {
                        self.descOfWork.text! += note.objectForKey("noteContent") as! String
                        self.descOfWork.text! += "\n\n"
                    }
                    
                    
                }
            }
        }
    }
    
    func updateTechLabel(notification : NSNotification) {
        let tech = notification.object as! String
        self.techLabel.text = tech
        self.selectedTech = self.techDict[tech]
        print(self.selectedTech)
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
                let sorted = GlobalFunctions().qsort(techList)
                print(techList)
                self.techDataSource = sorted
            }
        })
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
        case "Ready To Bill":
            statusCell.imageView?.image = UIImage(named: "WO Ready to Bill")
        case "Do not Bill":
            statusCell.imageView?.image = UIImage(named: "WO Do not Bill")
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
        
        if workOrderObject?.technicianPointer != nil {
            workOrderObject?.technicianPointer?.fetchInBackgroundWithBlock({ (employee : PFObject?, error : NSError?) in
                if error == nil {
                    let emp = employee as! Employee
                    self.techLabel.text! = emp.firstName + " " + emp.lastName
                    self.techLabel.textColor = UIColor.blackColor()
                } else {
                    self.techLabel.text = "Error Retrieving Assigned Tech"
                    self.techLabel.textColor = UIColor.redColor()
                }
            })
        }
        
        if workOrderObject?.workToBePerformed != nil {
            wtbpTextView.text = workOrderObject!.workToBePerformed
        }
        if workOrderObject?.descOfWork != nil {
            descOfWork.text = workOrderObject!.descOfWork
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
        
        if segue.identifier == "viewTrips" {
            let dest = segue.destinationViewController.childViewControllers.first as! TripsTableViewController
            if workOrderObject != nil {
                dest.workOrder = self.workOrderObject
            }
        }
        
        if segue.identifier == "techList" {
            let dest = segue.destinationViewController as! TechListTableViewController
            dest.techs = self.techDataSource
            dest.modalPresentationStyle = .Popover
            dest.popoverPresentationController!.delegate = self
            
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if cell?.reuseIdentifier == "datePromised" {
            toggleDatePromisedPicker()
        }
        
    }
    
    var datePromisedPickerHidden = true
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let datePromisedIndex = NSIndexPath(forRow: 1, inSection: 1)
        
        if datePromisedPickerHidden && (indexPath == datePromisedIndex){
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
    
    let calendar = NSCalendar.currentCalendar()
    
    @IBAction func datePromisedPickerAction(sender: AnyObject) {
        _ = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: wordOrderDatePicker.date, options: NSCalendarOptions())
        dateLabel.textColor = UIColor.blackColor()
        workOrderDatePickerChanged()
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
                if self.selectedTech != nil {
                    workOrderObject?.technicianPointer = self.selectedTech!
                }
            }
            if wtbpTextView.text.isEmpty == false {
                workOrderObject?.workToBePerformed = wtbpTextView.text
            }
            if descOfWork.text.isEmpty == false {
                workOrderObject?.descOfWork = descOfWork.text
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
        self.saveWithoutSeg()
    }
    
    func saveWithoutSeg() {
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
                if selectedTech != nil {
                    workOrderObject?.technicianPointer = self.selectedTech
                }
            }
            if wtbpTextView.text.isEmpty == false {
                workOrderObject?.workToBePerformed = wtbpTextView.text
            }
            if descOfWork.text.isEmpty == false {
                workOrderObject?.descOfWork = descOfWork.text
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
            workOrderObject?.status = statusLabel.text
            workOrderObject?.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                let sb = UIStoryboard(name: "WorkOrderPDFTemplate", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("workOrderPDF") as! WorkOrderPDFTemplateViewController
                vc.workOrderObject = self.workOrderObject
                self.presentViewController(vc, animated: true, completion: nil)
            })
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}

extension AddEditWorkOrderTableViewController : UITextViewDelegate {
    
}

extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}
