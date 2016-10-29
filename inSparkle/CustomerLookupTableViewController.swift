//
//  CustomerLookupTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class CustomerLookupTableViewController: UITableViewController, UISearchBarDelegate {
    
    var customerDataArray = [CustomerData]()
    var filteredData = [CustomerData]()
    var resultsSearchController = UISearchController()
    
    var selectedCustomer : CustomerData? = nil
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            self.customerDataArray.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.doTheParseSearch(searchBar.text!)
    }
    
    func doTheParseSearch(_ searchFor : String) {
        self.customerDataArray.removeAll()
        tableView.reloadData()
        var queries = [PFQuery]()
        let cust = CustomerData()
        let firstNameQuery = PFQuery(className: CustomerData.parseClassName())
        
        
        firstNameQuery.whereKey("firstName", contains: searchBar.text?.uppercased())
        queries.append(firstNameQuery)
        
        let lastNameQuery = PFQuery(className: CustomerData.parseClassName())
        
        lastNameQuery.whereKey("lastName", contains: searchBar.text?.uppercased())
        queries.append(lastNameQuery)
        
        let splitNameQuery1 = PFQuery(className: CustomerData.parseClassName())
        let splitNameQuery2 = PFQuery(className: CustomerData.parseClassName())
        let splitString = searchBar.text!.components(separatedBy: " ")
        let first = splitString.first
        let last = splitString.last
        
        splitNameQuery1.whereKey("fullName", contains: first?.uppercased())
        splitNameQuery2.whereKey("fullName", contains: last?.uppercased())
        queries.append(splitNameQuery1)
        queries.append(splitNameQuery2)
        
        let query = PFQuery.orQuery(withSubqueries: queries)
        query.order(byAscending: "lastName")
        query.findObjectsInBackground { (customers : [PFObject]?, error : Error?) -> Void in
            if error == nil {
                for cust in customers! {
                    let theCustomer = cust as! CustomerData
                    self.customerDataArray.append(theCustomer)
                    self.tableView.reloadData()
                    print(self.customerDataArray.count)
                }
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            return 40
        } else {
            return 120
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCell")!
            return cell
        } else {
            var cell = CustomerLookupTableViewCell()
            
            cell = tableView.dequeueReusableCell(withIdentifier: "customerCell") as! CustomerLookupTableViewCell
            print((indexPath as NSIndexPath).row)
            let customer = customerDataArray[(indexPath as NSIndexPath).row - 1] 
            
            cell.customerName.text = customer.firstName!.capitalized + " " + customer.lastName!.capitalized
            cell.addressStreet.text = customer.addressStreet.capitalized
            cell.addressRest.text = customer.addressCity.capitalized + ", " + customer.addressState.uppercased() + " " + customer.ZIP
            cell.phoneNumber.text = customer.phoneNumber
            if customer.currentBalance > 0 {
                print(customer.currentBalance)
                cell.balance.text = "$\(customer.currentBalance)"
            } else {
                cell.balance.isHidden = true
            }
            print(cell.editButton.tag)
            cell.editButton.tag = (((indexPath as NSIndexPath).row) - 1)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDataArray.count + 1
    }
    @IBAction func editCustomer(_ sender: UIButton) {
        let cell = CustomerLookupTableViewCell()
        let editTag = sender.tag
        let customerObj : CustomerData = customerDataArray[editTag]
        AddEditCustomers.theCustomer = customerObj
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fromVC = CustomerLookupObjects.fromVC
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            // Do nothing
        } else {
            let selectedCx = self.customerDataArray[(indexPath as NSIndexPath).row - 1]
            globalSelectedCx = selectedCx
            if fromVC == "AddSchedule" {
                CustomerLookupObjects.slectedCustomer = selectedCx
                CustomerLookupObjects.fromVC = nil
                NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFieldsOnSchedule"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            if fromVC == "NewMessage" {
                CustomerLookupObjects.slectedCustomer = selectedCx
                CustomerLookupObjects.fromVC = nil
                NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFieldsOnNewMessage"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            if fromVC == "AddEditWorkOrder" {
                CustomerLookupObjects.slectedCustomer = selectedCx
                CustomerLookupObjects.fromVC = nil
                NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateFieldsOnAddEditWorkOrder"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            if fromVC == "More" {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var globalSelectedCx : CustomerData!
}
