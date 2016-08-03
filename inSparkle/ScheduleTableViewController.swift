//
//  ScheduleTableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/30/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class ScheduleTableViewController: UITableViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    var scheduleArray : NSMutableArray = []
    var filterOption : String!
    var objectsToEdit : [ScheduleObject] = []
    
    @IBOutlet weak var openCloseSegControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setContentOffset(CGPointMake(0, searchBar.frame.size.height), animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "NotifyScheduleTableToRefresh", object: nil)
        
        setFilterType()
        scheduleQuery()
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
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
        
        if scheduleArray.count > 0 && scheduleArray.count > indexPath.row {
            let object = scheduleArray.objectAtIndex(indexPath.row) as! ScheduleObject
            
            let customerName = object.valueForKey("customerName") as! String
            var weekStart : NSDate! = nil
            var weekEnd : NSDate! = nil
            
            if object.confirmedDate != nil {
                weekStart = object.confirmedDate!
                weekEnd = object.confirmedDate!
            } else {
                weekStart = object.valueForKey("weekStart") as! NSDate
                weekEnd = object.valueForKey("weekEnd") as! NSDate
            }
            
            
            
            var isConfirmed : Bool?
            if object.confrimed != nil {
                if object.confrimed! {
                    isConfirmed = true
                } else {
                    isConfirmed = false
                }
            } else {
                isConfirmed = false
            }
            
            cell.scheduleCell(customerName, weekStart: weekStart, weekEnd: weekEnd, isConfirmed: isConfirmed! )
            
        } else {
            self.refresh()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func scheduleQuery() {
        
        let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.view, navController: self.navigationController!)
        loadingUI = returnUI
        loadingBackground = returnBG
        
        let query : PFQuery = PFQuery(className: "Schedule")
        query.whereKey("isActive", equalTo: true)
        query.whereKey("type", equalTo: filterOption)
        query.limit = 1000
        query.orderByAscending("weekStart")
        query.findObjectsInBackgroundWithBlock { (scheduleObjects :[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.scheduleArray.removeAllObjects()
                for object in scheduleObjects! {
                    self.scheduleArray.addObject(object)
                    self.tableView.reloadData()
                    self.loadingUI.stopAnimation()
                    self.loadingBackground.removeFromSuperview()
                }
            }
        }
        if (self.refreshControl!.refreshing) {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.tableView.editing {
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
        } else if self.tableView.editing == true {
            let theObject = scheduleArray[indexPath.row] as! ScheduleObject
            objectsToEdit.append(theObject)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing == true {
            let theObject = scheduleArray[indexPath.row] as! ScheduleObject
            let objIndex = self.objectsToEdit.indexOf(theObject)
            self.objectsToEdit.removeAtIndex(objIndex!)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            let actionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(ScheduleTableViewController.actionSelection))
            self.navigationItem.rightBarButtonItem = actionButton
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ScheduleTableViewController.segToAdd(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
        
    }
    
    func actionSelection() {
        let actionSheet = UIAlertController(title: "Select Action", message: nil, preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            self.deletePOCs()
        }
        let setDateAction = UIAlertAction(title: "Set Date", style: .Default) { (action) in
            self.setDate()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        actionSheet.addAction(setDateAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelButton)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func setDate() {
        var dateTextField : UITextField!
        let dateAlert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .Alert)
        dateAlert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "mm/dd/yy"
            dateTextField = textField
        }
        let setDates = UIAlertAction(title: "Save", style: .Default) { (action) in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            
            for obj in self.objectsToEdit {
                let date : NSDate? = dateFormatter.dateFromString(dateTextField.text!)
                if date != nil {
                    obj.confirmedDate = date!
                    PFObject.saveAllInBackground(self.objectsToEdit, block: { (success : Bool, error : NSError?) in
                        if success {
                            self.objectsToEdit.removeAll()
                            self.refresh()
                        }
                    })
                } else {
                    let errorAlert = UIAlertController(title: "Check Date", message: "Unable to set date with the entered date, check your date is in the correct format and try again.", preferredStyle: .Alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    errorAlert.addAction(okayButton)
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        dateAlert.addAction(cancelButton)
        dateAlert.addAction(setDates)
        self.presentViewController(dateAlert, animated: true, completion: nil)
    }
    
    func deletePOCs() {
        let indexPaths = self.tableView.indexPathsForSelectedRows
        print(indexPaths)
        for obj in objectsToEdit {
            obj.isActive = false
        }
        PFObject.saveAllInBackground(self.objectsToEdit) { (success : Bool, error : NSError?) in
            if success {
                self.objectsToEdit.removeAll()
                self.refresh()
            }
        }
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
        if editingStyle == .Delete && self.objectsToEdit.count == 0 {
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
        let alert = UIAlertController(title: "Confirmed", message: "The POC has been confirmed", preferredStyle: .Alert)
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
            query.whereKey("customerName", containsString: searchBar.text!.capitalizedString)
            query.findObjectsInBackgroundWithBlock { (scheduleObjects :[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.scheduleArray.removeAllObjects()
                    for object in scheduleObjects! {
                        self.scheduleArray.addObject(object)
                    }
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesInRange: range)
                    self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
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
