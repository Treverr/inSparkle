//
//  WorkOrderStatusTableViewController.swift
//  
//
//  Created by Trever on 2/24/16.
//
//

import UIKit

class WorkOrderStatusTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let selectedStatus = cell?.textLabel?.text!
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatusLabel", object: selectedStatus)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
