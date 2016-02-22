//
//  AddEditWorkOderTableViewController.swift
//  
//
//  Created by Trever on 2/22/16.
//
//

import UIKit

class AddEditWorkOderTableViewController: UITableViewController {

    @IBOutlet var customerNameTextField: UITextField!
    @IBOutlet var customerAddressTextField: UITextField!
    @IBOutlet var customerPhoneTextField: UITextField!
    @IBOutlet var customerAltPhoneTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}
