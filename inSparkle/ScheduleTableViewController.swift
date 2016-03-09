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
    
    @IBOutlet var searchBar: UISearchBar!
    
    var scheduleArray : NSMutableArray = []
    var filterOption : String!
    
    @IBOutlet weak var openCloseSegControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setContentOffset(CGPointMake(0, searchBar.frame.size.height), animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "NotifyScheduleTableToRefresh", object: nil)
        
        setFilterType()
        scheduleQuery()
        setupNavigationbar()
        
        self.navigationItem.leftBarButtonItem = editButtonItem()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayConfirmed", name: "NotifyAppointmentConfirmed", object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = Colors.sparkleGreen
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)
        
        searchBar.delegate = self
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell") as! ScheduleTableViewCell
        
        let object = scheduleArray.objectAtIndex(indexPath.row)
        
        let customerName = object.valueForKey("customerName") as! String
        let weekStart = object.valueForKey("weekStart") as! NSDate
        let weekEnd = object.valueForKey("weekEnd") as! NSDate
        
        var isConfirmed : Bool?
        if object.valueForKey("confrimedBy") != nil {
            isConfirmed = true
        } else {
            isConfirmed = false
        }
        
        cell.scheduleCell(customerName, weekStart: weekStart, weekEnd: weekEnd, isConfirmed: isConfirmed! )
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func scheduleQuery() {
        let query : PFQuery = PFQuery(className: "Schedule")
        query.whereKey("isActive", equalTo: true)
        query.whereKey("type", equalTo: filterOption)
        query.orderByAscending("weekStart")
        query.findObjectsInBackgroundWithBlock { (scheduleObjects :[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.scheduleArray.removeAllObjects()
                for object in scheduleObjects! {
                    self.scheduleArray.addObject(object)
                    self.tableView.reloadData()
                }
            }
        }
        if (self.refreshControl!.refreshing) {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let scheduledObject = self.scheduleArray[indexPath.row] as! ScheduleObject
        AddNewScheduleObjects.scheduledObject = scheduledObject
        switch openCloseSegControl.selectedSegmentIndex {
        case 0:
            AddNewScheduleObjects.isOpening = true
        case 1:
            AddNewScheduleObjects.isOpening = false
        default:
            break
        }
        let sb = UIStoryboard(name: "Schedule", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("addEditSche")
        self.presentViewController(vc, animated: true, completion: nil)
        
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
        self.tableView.reloadData()
        filterOption = "Opening"
        scheduleQuery()
    }
    
    func runCloseFilter() {
        scheduleArray.removeAllObjects()
        self.tableView.reloadData()
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
        self.tableView.reloadData()
        scheduleQuery()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var reason : UITextField?
            let alert = UIAlertController(title: "Reason for Cancelation", message: "Please enter a reason for cancelation", preferredStyle: .Alert)
            let confirmCancel = UIAlertAction(title: "Confirm Cancel", style: .Destructive, handler: { (action) -> Void in
                var deletingObject : ScheduleObject!
                deletingObject = self.scheduleArray.objectAtIndex(indexPath.row)
                    as! ScheduleObject
                deletingObject.isActive = false
                deletingObject.cancelReason = reason!.text!
                deletingObject.weekObj.fetchInBackgroundWithBlock({ (weekObj : PFObject?, error :NSError?) -> Void in
                    if error == nil {
                        let theWeek = weekObj as! WeekList
                        theWeek.numApptsSch = theWeek.numApptsSch - 1
                        theWeek.apptsRemain = theWeek.apptsRemain + 1
                        theWeek.saveEventually()
                    }
                })
                deletingObject.saveEventually()
                let weekRange = "\(GlobalFunctions().stringFromDateShortStyle(deletingObject.weekStart)) - \(GlobalFunctions().stringFromDateShortStyle(deletingObject.weekEnd))"
                CloudCode.AlertOfCancelation(deletingObject.customerName, address: deletingObject.customerAddress.capitalizedString, phone: deletingObject.customerPhone, reason: reason!.text!, cancelBy: PFUser.currentUser()!.username!.capitalizedString, theDates: weekRange, theType: deletingObject.type)
                self.scheduleArray.removeObjectAtIndex(indexPath.row)
                tableView.reloadData()

            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "reason"
                textField.keyboardType = .Default
                reason = textField
            })
            alert.addAction(confirmCancel)
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
           
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
            AddNewScheduleObjects.isOpening = true
            let VC = storyboard.instantiateViewControllerWithIdentifier("addEditSche")
            self.presentViewController(VC, animated: true, completion: nil)
        }
        let closingButton = UIAlertAction(title: "Closing", style: .Default) { (ACTION) -> Void in
            AddNewScheduleObjects.isOpening = false
            let VC = storyboard.instantiateViewControllerWithIdentifier("addEditSche")
            self.presentViewController(VC, animated: true, completion: nil)
        }

        alert.addAction(openingButton)
        alert.addAction(closingButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayConfirmed() {
        let alert = UIAlertController(title: "Confirmed", message: "The POC has been confriemd", preferredStyle: .Alert)
        let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alert.addAction(okayButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ScheduleTableViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.scheduleArray.removeAllObjects()
        self.scheduleQuery()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            scheduleArray.removeAllObjects()
            let query : PFQuery = PFQuery(className: "Schedule")
            query.whereKey("isActive", equalTo: true)
            query.whereKey("type", equalTo: filterOption)
            query.orderByAscending("weekStart")
            query.whereKey("customerName", containsString: searchBar.text!)
            query.findObjectsInBackgroundWithBlock { (scheduleObjects :[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.scheduleArray.removeAllObjects()
                    for object in scheduleObjects! {
                        self.scheduleArray.addObject(object)
                        self.tableView.reloadData()
                    }
                }
            }
            if (self.refreshControl!.refreshing) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.scheduleArray.removeAllObjects()
            self.scheduleQuery()
        }
    }
}
