//
//  ReactivePOCTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ReactivePOCTableViewController: UITableViewController {
    
    var inactivePOCs = [ScheduleObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Cancelled POC's"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getInactivePOCs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.inactivePOCs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let swipeAlert = UIAlertController(title: "Try Swipping from the left", message: "Want to re-activate? Swipe from the right and choose 'Re-Activate'", preferredStyle: .Alert)
        let okay = UIAlertAction(title: "Okay", style: .Default) { (action) in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        swipeAlert.addAction(okay)
        self.presentViewController(swipeAlert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction : UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "Re-Activate") { (action, indexPath : NSIndexPath) in
            let row = indexPath.row
            let item = self.inactivePOCs[row]
            
            item.isActive = true
            item.saveInBackground()
            self.inactivePOCs.removeAtIndex(row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        return [editAction]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("reactivateCell") as! ReActivePOCTableViewCell
        let indexRow = indexPath.row
        
        cell.configureCell(inactivePOCs[indexRow].customerName, weekStart: inactivePOCs[indexRow].weekStart, weekEnd: inactivePOCs[indexRow].weekEnd, cancelReason: inactivePOCs[indexRow].cancelReason)
        
        return cell
        
    }
    
    func getInactivePOCs() {
        let query = ScheduleObject.query()
        query?.whereKey("isActive", equalTo: false)
        query?.orderByAscending("weekStart")
        query?.findObjectsInBackgroundWithBlock({ (inactivePOCs : [PFObject]?, error : NSError?) in
            self.inactivePOCs = inactivePOCs as! [ScheduleObject]
            self.tableView.reloadData()
        })
        
    }

}
