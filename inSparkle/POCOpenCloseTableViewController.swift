//
//  POCOpenCloseTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class POCOpenCloseTableViewController: UITableViewController {
    
    var filter = POCReportFilters.filter

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openings" {
            POCReportFilters.filter.append("Opening")
        }
        if segue.identifier == "closings" {
            POCReportFilters.filter.append("Closing")
        }
    }

}
