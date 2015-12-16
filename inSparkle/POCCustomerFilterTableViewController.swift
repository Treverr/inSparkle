//
//  POCCustomerFilterTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class POCCustomerFilterTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var filters = POCReportFilters.filter

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "POC Report"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateStart", name: "NotifyPOCUpdateStartLabel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEnd", name: "NotifyPOCUpdateEndLabel", object: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "allCustomers" {
            POCReportFilters.filter.append("allCustomers")
        }
    }
    
    
}
