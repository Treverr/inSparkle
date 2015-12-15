//
//  POCActiveInactiveAllFilterTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/14/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit

class POCActiveInactiveAllFilterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "inactive" {
            POCReportFilters.filter.append("inactive")
        }
        if segue.identifier == "all" {
            POCReportFilters.filter.append("all")
        }
        if segue.identifier == "active" {
            POCReportFilters.filter.append("active")
        }
        print(POCReportFilters.filter)
    }

}
