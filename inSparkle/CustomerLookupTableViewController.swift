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
        
        
    }
    
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.characters.count > 3 {
           doTheParseSearch(searchBar.text!)
        }
    }
    
    func doTheParseSearch(searchFor : String) {
        let cust = CustomerData()
        var firstNameQuery = PFQuery(className: CustomerData.parseClassName())
        firstNameQuery?.whereKey(cust.firstName, equalTo: searchFor)
        
        
        var lastNameQuery = PFQuery(className: CustomerData.parseClassName())
        lastNameQuery?.whereKey(cust.lastName, equalTo: searchFor)
        
        
        var query = PFQuery.orQueryWithSubqueries([firstNameQuery])
        query.findObjectsInBackgroundWithBlock { (customers : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                for cust in customers {
                    let theCustomer = cust as! CustomerData
                    customerDataArray.append(theCustomer)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customerCell") as! CustomerLookupTableViewCell
        let customer = customerDataArray[indexPath.row] as! CustomerData
        
        cell.customerName = customer.firstName + " " + customer.lastName
        cell.addressStreet = customer.addressStreet
        cell.addressRest = customer.addressCity + " " + customer.addressState + ", " + customer.ZIP
        cell.phoneNumber = customer.phoneNumber
        cell.balance = customer.currentBalance!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerDataArray.count!
    }
    
}