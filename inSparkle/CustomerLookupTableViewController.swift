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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        setupNavigationbar()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            self.customerDataArray.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.doTheParseSearch(searchBar.text!)
    }
    
    func doTheParseSearch(searchFor : String) {
        self.customerDataArray.removeAll()
        tableView.reloadData()
        var queries = [PFQuery]()
        let cust = CustomerData()
        var firstNameQuery = PFQuery(className: CustomerData.parseClassName())
        
        
        firstNameQuery.whereKey("firstName", containsString: searchBar.text?.uppercaseString)
        queries.append(firstNameQuery)
        
        var lastNameQuery = PFQuery(className: CustomerData.parseClassName())
        
        lastNameQuery.whereKey("lastName", containsString: searchBar.text?.uppercaseString)
        queries.append(lastNameQuery)
        
        let splitNameQuery1 = PFQuery(className: CustomerData.parseClassName())
        let splitNameQuery2 = PFQuery(className: CustomerData.parseClassName())
        let splitString = searchBar.text!.componentsSeparatedByString(" ")
        let first = splitString.first
        let last = splitString.last

        splitNameQuery1.whereKey("fullName", containsString: first?.uppercaseString)
        splitNameQuery2.whereKey("fullName", containsString: last?.uppercaseString)
        queries.append(splitNameQuery1)
        queries.append(splitNameQuery2)
        
        var query = PFQuery.orQueryWithSubqueries(queries)
        query.orderByAscending("lastName")
        query.findObjectsInBackgroundWithBlock { (customers : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                for cust in customers! {
                    let theCustomer = cust as! CustomerData
                    self.customerDataArray.append(theCustomer)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 40
        } else {
            return 91
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addCell")!
            
            return cell
        } else {
            var cell = CustomerLookupTableViewCell()
            cell = tableView.dequeueReusableCellWithIdentifier("customerCell") as! CustomerLookupTableViewCell
            let customer = customerDataArray[indexPath.row] as! CustomerData
            
            cell.customerName.text = customer.firstName!.capitalizedString + " " + customer.lastName!.capitalizedString
            cell.addressStreet.text = customer.addressStreet.capitalizedString
            cell.addressRest.text = customer.addressCity.capitalizedString + " " + customer.addressState.uppercaseString + ", " + customer.ZIP
            cell.phoneNumber.text = customer.phoneNumber
            if customer.currentBalance > 2 {
                cell.balance.text = String(customer.currentBalance)
            } else {
                cell.balance.hidden = true
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDataArray.count + 1
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
}