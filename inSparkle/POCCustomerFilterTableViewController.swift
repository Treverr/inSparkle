//
//  POCCustomerFilterTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class POCCustomerFilterTableViewController: UITableViewController {
    
    var filters = POCReportFilters.filter

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "POC Report"
        
        setupNavigationbar()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "allCustomers" {
            POCReportFilters.filter.append("allCustomers")
        }
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            POCReportFilters.filter.removeAll()
        }
    }
}
