//
//  ScheduleTableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/30/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ScheduleTableViewController: UITableViewController {
    
    var scheduleArray : NSMutableArray = []
    var filterOption : String!
    
    @IBOutlet weak var openCloseSegControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "NotifyScheduleTableToRefresh", object: nil)
        
        setFilterType()
        scheduleQuery()
        setupNavigationbar()
        
        self.navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell") as! ScheduleTableViewCell
        
        let object = scheduleArray.objectAtIndex(indexPath.row)
        
        let customerName = object.valueForKey("customerName") as! String
        let weekStart = object.valueForKey("weekStart") as! NSDate
        let weekEnd = object.valueForKey("weekEnd") as! NSDate
        
        cell.scheduleCell(customerName, weekStart: weekStart, weekEnd: weekEnd)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func scheduleQuery() {
        let query : PFQuery = PFQuery(className: "Schedule")
        query.whereKey("isActive", equalTo: true)
        query.whereKey("type", equalTo: filterOption)
        query.orderByDescending("weekStart")
        query.findObjectsInBackgroundWithBlock { (scheduleObjects :[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in scheduleObjects! {
                    self.scheduleArray.addObject(object)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    @IBAction func openCloseSegControl(sender: AnyObject) {
        switch openCloseSegControl.selectedSegmentIndex {
        case 0: runOpenFilter()
        case 1: runCloseFilter()
        default: break
        }
    }
    
    func runOpenFilter() {
        scheduleArray.removeAllObjects()
        filterOption = "Opening"
        scheduleQuery()
    }
    
    func runCloseFilter() {
        scheduleArray.removeAllObjects()
        filterOption = "Closing"
        scheduleQuery()
    }
    
    func setFilterType() {
        if filterOption == nil {
            filterOption = "Opening"
        }
    }
    
    func refresh() {
        scheduleArray.removeAllObjects()
        scheduleQuery()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var deletingObject : ScheduleObject!
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            deletingObject = scheduleArray.objectAtIndex(indexPath.row)
             as! ScheduleObject
            deletingObject.isActive = false
            deletingObject.saveEventually()
            scheduleArray.removeObjectAtIndex(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        var returnValue : String?
        switch openCloseSegControl.selectedSegmentIndex {
        case 0: returnValue = "Cancel Opening"
        case 1: returnValue = "Cancel Closing"
        default: break
        }
        
        return returnValue!
    }
    @IBAction func segToAdd(sender: AnyObject) {
       let alert = UIAlertController(title: "Type?", message: "Is this an opening or closing?", preferredStyle: .Alert)
        let storyboard = UIStoryboard(name: "Schedule", bundle: nil)
        
        let openingButton = UIAlertAction(title: "Opening", style: .Default) { (action) -> Void in
            let closeVC = storyboard.instantiateViewControllerWithIdentifier("opening")
            self.presentViewController(closeVC, animated: true, completion: nil)
        }
        let closingButton = UIAlertAction(title: "Closing", style: .Default) { (ACTION) -> Void in
            let openVC = storyboard.instantiateViewControllerWithIdentifier("opening")
            self.presentViewController(openVC, animated: true, completion: nil)
        }
        alert.addAction(openingButton)
        alert.addAction(closingButton)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}
