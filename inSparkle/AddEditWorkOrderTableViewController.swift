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
        
        wordOrderDatePicker.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdateCustomerFields), name: NSNotification.Name(rawValue: "UpdateFieldsOnAddEditWorkOrder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdatePartsArray(_:)), name: NSNotification.Name(rawValue: "UpdatePartsArray"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.UpdateLaborArray(_:)), name: NSNotification.Name(rawValue: "UpdateLaborArray"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.updateStatusLabel(_:)), name: NSNotification.Name(rawValue: "updateStatusLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditWorkOrderTableViewController.updateTechLabel(_:)), name: NSNotification.Name(rawValue: "updateTechLabel"), object: nil)
        
        
    }
    
    func getMTNotes() {
        let query = PFQuery(className: "MobileTechServiceObjectNotes")
        query.whereKey("relatedWorkOder", equalTo: self.workOrderObject!)
        query.findObjectsInBackground { (notes : [PFObject]?, error : Error?) in
            if error == nil {
                for note in notes! {
                    if note == notes?.last {
                        self.descOfWork.text! += note.object(forKey: "noteContent") as! String
                    } else {
                        self.descOfWork.text! += note.object(forKey: "noteContent") as! String
                        self.descOfWork.text! += "\n\n"
                    }
                }
            }
        }
    }
    
    func updateTechLabel(_ notification : Notification) {
        let tech = notification.object as! String
        self.techLabel.text = tech
        self.selectedTech = self.techDict[tech]
        print(self.selectedTech)
    }
    
    func getTechs() {
        let techs = Employee.query()
        techs?.whereKey("active", equalTo: true)
        techs?.order(byAscending: "firstName")
        techs?.findObjectsInBackground(block: { (techs : [PFObject]?, error : Error?) in
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
                let sorted = techList.sorted()
                print(techList)
                self.techDataSource = sorted
            }
        })
    }
    
    func updateStatusLabel(_ notification : Notification) {
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
            dateLabel.textColor = UIColor.black
        }
        if workOrderObject?.technician != nil {
            techLabel.text = workOrderObject!.technician!
            techLabel.textColor = UIColor.black
        }
        
        if workOrderObject?.technicianPointer != nil {
            workOrderObject?.technicianPointer?.fetchInBackground(block: { (employee : PFObject?, error : Error?) in
                if error == nil {
                    let emp = employee as! Employee
                    self.techLabel.text! = emp.firstName + " " + emp.lastName
                    self.techLabel.textColor = UIColor.black
                } else {
                    self.techLabel.text = "Error Retrieving Assigned Tech"
                    self.techLabel.textColor = UIColor.red
                }
            })
        }
        
        if workOrderObject?.workToBePerformed != nil {
            wtbpTextView.text = workOrderObject!.workToBePerformed
        }
//        if workOrderObject?.descOfWork != nil {
//            descOfWork.text = workOrderObject!.descOfWork
//        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customerLookup" {
            CustomerLookupObjects.fromVC = "AddEditWorkOrder"
        }
        if segue.identifier == "parts" {
            let dest = segue.destination as! WorkOrderPartsTableViewController
            if parts != nil {
                if parts.count != 0 {
                    dest.parts = self.parts
                }
            }
        }
        if segue.identifier == "labor" {
            let dest = segue.destination as! LaborPartsTableViewController
            if self.labor != nil {
                if self.labor.count != 0 {
                    dest.labor = self.labor
                }
            }
        }
        
        if segue.identifier == "viewTrips" {
            let dest = segue.destination.childViewControllers.first as! TripsTableViewController
            if workOrderObject != nil {
                dest.workOrder = self.workOrderObject
            }
        }
        
        if segue.identifier == "techList" {
            let dest = segue.destination as! TechListTableViewController
            dest.techs = self.techDataSource
            dest.modalPresentationStyle = .popover
            dest.popoverPresentationController!.delegate = self
            
        }
    }
    
    func UpdatePartsArray(_ notification : Notification) {
        self.parts = notification.object as! [String]
        if parts.count != 0 {
            managePartsLabel.text = "Manage Parts (\(self.parts.count))"
        }
        if parts.count == 0 {
            managePartsLabel.text = "Manage Labor"
        }
    }
    
    func UpdateLaborArray(_ notification : Notification) {
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
        
        customerNameTextField.text = selectCx!.firstName!.capitalized + " " + selectCx!.lastName!.capitalized
        customerPhoneTextField.text = selectCx!.phoneNumber
        customerAddressTextField.text = "\(selectCx!.addressStreet.capitalized) \(selectCx!.addressCity.capitalized), \(selectCx!.addressState) \(selectCx!.ZIP)"
    }
    
    func workOrderDatePickerChanged() {
        dateLabel.text = DateFormatter.localizedString(from: wordOrderDatePicker.date, dateStyle: .short, timeStyle: .none)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if cell?.reuseIdentifier == "datePromised" {
            toggleDatePromisedPicker()
        }
        
    }
    
    var datePromisedPickerHidden = true
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let datePromisedIndex = IndexPath(row: 1, section: 1)
        
        if datePromisedPickerHidden && (indexPath == datePromisedIndex){
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func toggleDatePromisedPicker() {
        datePromisedPickerHidden = !datePromisedPickerHidden
        
        if wordOrderDatePicker.isHidden {
            wordOrderDatePicker.isHidden = false
        } else {
            wordOrderDatePicker.isHidden = true
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableViewScrollToBottom(_ animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    
    let calendar = Calendar.current
    
    @IBAction func datePromisedPickerAction(_ sender: AnyObject) {
        _ = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: wordOrderDatePicker.date, options: NSCalendar.Options())
        dateLabel.textColor = UIColor.black
        workOrderDatePickerChanged()
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        if customerNameTextField.text!.isEmpty || customerAddressTextField.text!.isEmpty || customerPhoneTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Customer Data", message: "There seems to be required data missing from the customer infromation, please check and try again.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
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
                    workOrderObject?.parts = self.parts as NSArray?
                }
            }
            if self.labor != nil {
                if self.labor.count == 0 {
                    workOrderObject?.labor? = []
                } else {
                    workOrderObject?.labor = self.labor as NSArray?
                }
            }
            workOrderObject?.status = statusLabel.text
            print(workOrderObject)
            workOrderObject?.saveInBackground(block: { (success : Bool, error : Error?) in
                if success == true {
                    let successAlert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
                    self.present(successAlert, animated: true, completion: {
                        let delay = 1.0 * Double(NSEC_PER_SEC)
                        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                        
                        DispatchQueue.main.asyncAfter(deadline: time, execute: {
                            self.dismiss(animated: true, completion: {
                                self.performSegue(withIdentifier: "unwindToWOMain", sender: nil)
                            })
                        })
                    })
                }
                if error != nil {
                    let errorAlert = UIAlertController(title: "Error", message: "There was an error attempting to save the work order, please try again.", preferredStyle: .alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    errorAlert.addAction(okayButton)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func generatePDF(_ sender: AnyObject) {
        self.saveWithoutSeg()
    }
    
    func saveWithoutSeg() {
        if customerNameTextField.text!.isEmpty || customerAddressTextField.text!.isEmpty || customerPhoneTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Customer Data", message: "There seems to be required data missing from the customer infromation, please check and try again.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
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
                    workOrderObject?.parts = self.parts as NSArray?
                }
            }
            if self.labor != nil {
                if self.labor.count == 0 {
                    workOrderObject?.labor? = []
                } else {
                    workOrderObject?.labor = self.labor as NSArray?
                }
            }
            workOrderObject?.status = statusLabel.text
            workOrderObject?.saveInBackground(block: { (success : Bool, error : Error?) in
                let sb = UIStoryboard(name: "WorkOrderPDFTemplate", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "workOrderPDF") as! WorkOrderPDFTemplateViewController
                vc.workOrderObject = self.workOrderObject
                let theView = vc.view
                
            })
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
}

extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}
