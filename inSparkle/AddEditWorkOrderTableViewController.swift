//
//  AddEditWorkOderTableViewController.swift
//  
//
//  Created by Trever on 2/22/16.
//
//

import UIKit

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
    
    @IBOutlet var wordOrderDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wtbpTextView.delegate = self
        
        workOrderDatePickerChanged()
        wordOrderDatePicker.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("UpdateCustomerFields"), name: "UpdateFieldsOnAddEditWorkOrder", object: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "customerLookup" {
            CustomerLookupObjects.fromVC = "AddEditWorkOrder"
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
    
    
    @IBAction func datePromisedPickerAction(sender: AnyObject) {
        dateLabel.textColor = UIColor.blackColor()
        workOrderDatePickerChanged()
    }

}

extension AddEditWorkOrderTableViewController : UITextViewDelegate {
    
}
