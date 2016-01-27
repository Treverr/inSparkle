//
//  MessageStatusTableViewController.swift
//  
//
//  Created by Trever on 1/26/16.
//
//

import UIKit

class MessageStatusTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var selectedStatus : String!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        selectedStatus = cell?.textLabel?.text!
        print(selectedStatus)
        self.performSegueWithIdentifier("updateStatusLabel", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateStatusLabel" {
            let dest = segue.destinationViewController as! ComposeMessageTableViewController
            dest.statusLabel.text = "Status: " + selectedStatus
            
        }
    }

}
