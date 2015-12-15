//
//  POCCustomerFilterTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class POCCustomerFilterTableViewController: UITableViewController {
    
    var filters = POCReportFilters.filter

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "allCustomers" {
            filters?.append("allCustomers")
        }
    }

}
