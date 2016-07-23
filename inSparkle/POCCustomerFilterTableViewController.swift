//
//  POCCustomerFilterTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class POCAdminTableViewController: UITableViewController {
    
    var filters = POCReportFilters.filter

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "POC Report"
        
        self.navigationController?.setupNavigationbar(self.navigationController!)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "allCustomers" {
            POCReportFilters.filter.append("allCustomers")
        }
    }

    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            POCReportFilters.filter.removeAll()
        }
    }
}
