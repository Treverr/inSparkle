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
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.size.height), animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.refresh), name: NSNotification.Name(rawValue: "NotifyScheduleTableToRefresh"), object: nil)
        
        setFilterType()
        scheduleQuery()
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleTableViewController.displayConfirmed), name: NSNotification.Name(rawValue: "NotifyAppointmentConfirmed"), object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = Colors.sparkleGreen
        self.refreshControl!.tintColor = UIColor.white
        self.refreshControl!.addTarget(self, action: #selector(ScheduleTableViewController.refresh), for: .valueChanged)
        
        searchBar.delegate = self
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as! ScheduleTableViewCell
        
        if scheduleArray.count > 0 && scheduleArray.count > (indexPath as NSIndexPath).row {
            let object = scheduleArray.object(at: (indexPath as NSIndexPath).row) as! ScheduleObject
            
            let customerName = object.value(forKey: "customerName") as! String
            var weekStart : Date! = nil
            var weekEnd : Date! = nil
            
            if object.confirmedDate != nil {
                weekStart = object.confirmedDate! as Date!
                weekEnd = object.confirmedDate! as Date!
            } else {
                weekStart = object.value(forKey: "weekStart") as! Date
                weekEnd = object.value(forKey: "weekEnd") as! Date
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        query.order(byAscending: "weekStart")
        query.findObjectsInBackground { (scheduleObjects :[PFObject]?, error: Error?) -> Void in
            if error == nil {
                self.scheduleArray.removeAllObjects()
                for object in scheduleObjects! {
                    self.scheduleArray.add(object)
                    self.tableView.reloadData()
                    self.loadingUI.stopAnimating()
                    self.loadingBackground.removeFromSuperview()
                }
            }
        }
        if (self.refreshControl!.isRefreshing) {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.tableView.isEditing {
            let scheduledObject = self.scheduleArray[(indexPath as NSIndexPath).row] as! ScheduleObject
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
            let vc = sb.instantiateViewController(withIdentifier: "addEditSche")
            self.present(vc, animated: true, completion: nil)
        } else if self.tableView.isEditing == true {
            let theObject = scheduleArray[(indexPath as NSIndexPath).row] as! ScheduleObject
            objectsToEdit.append(theObject)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            let theObject = scheduleArray[(indexPath as NSIndexPath).row] as! ScheduleObject
            let objIndex = self.objectsToEdit.index(of: theObject)
            self.objectsToEdit.remove(at: objIndex!)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ScheduleTableViewController.actionSelection))
            self.navigationItem.rightBarButtonItem = actionButton
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ScheduleTableViewController.segToAdd(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        }
        
    }
    
    func actionSelection() {
        let actionSheet = UIAlertController(title: "Select Action", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deletePOCs()
        }
        let setDateAction = UIAlertAction(title: "Set Date", style: .default) { (action) in
            self.setDate()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(setDateAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelButton)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setDate() {
        var dateTextField : UITextField!
        let dateAlert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .alert)
        dateAlert.addTextField { (textField) in
            textField.placeholder = "mm/dd/yy"
            dateTextField = textField
        }
        let setDates = UIAlertAction(title: "Save", style: .default) { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            
            for obj in self.objectsToEdit {
                let date : Date? = dateFormatter.date(from: dateTextField.text!)
                if date != nil {
                    obj.confirmedDate = date!
                    PFObject.saveAll(inBackground: self.objectsToEdit, block: { (success : Bool, error : Error?) in
                        if success {
                            self.objectsToEdit.removeAll()
                            self.refresh()
                        }
                    })
                } else {
                    let errorAlert = UIAlertController(title: "Check Date", message: "Unable to set date with the entered date, check your date is in the correct format and try again.", preferredStyle: .alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    errorAlert.addAction(okayButton)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        dateAlert.addAction(cancelButton)
        dateAlert.addAction(setDates)
        self.present(dateAlert, animated: true, completion: nil)
    }
    
    func deletePOCs() {
        let indexPaths = self.tableView.indexPathsForSelectedRows
        print(indexPaths)
        for obj in objectsToEdit {
            obj.isActive = false
        }
        PFObject.saveAll(inBackground: self.objectsToEdit) { (success : Bool, error : Error?) in
            if success {
                self.objectsToEdit.removeAll()
                self.refresh()
            }
        }
    }
    
    @IBAction func openCloseSegControl(_ sender: AnyObject) {
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && self.objectsToEdit.count == 0 {
            var reason : UITextField?
            let alert = UIAlertController(title: "Reason for Cancelation", message: "Please enter a reason for cancelation", preferredStyle: .alert)
            let confirmCancel = UIAlertAction(title: "Confirm Cancel", style: .destructive, handler: { (action) -> Void in
                var deletingObject : ScheduleObject!
                deletingObject = self.scheduleArray.object(at: (indexPath as NSIndexPath).row)
                    as! ScheduleObject
                deletingObject.isActive = false
                deletingObject.cancelReason = reason!.text!
                deletingObject.weekObj.fetchInBackground(block: { (weekObj : PFObject?, error :Error?) -> Void in
                    if error == nil {
                        let theWeek = weekObj as! WeekList
                        theWeek.numApptsSch = theWeek.numApptsSch - 1
                        theWeek.apptsRemain = theWeek.apptsRemain + 1
                        theWeek.saveEventually()
                    }
                })
                deletingObject.saveEventually()
                let weekRange = "\(GlobalFunctions().stringFromDateShortStyle(deletingObject.weekStart)) - \(GlobalFunctions().stringFromDateShortStyle(deletingObject.weekEnd))"
                CloudCode.AlertOfCancelation(deletingObject.customerName, address: deletingObject.customerAddress.capitalized, phone: deletingObject.customerPhone, reason: reason!.text!, cancelBy: PFUser.current()!.username!.capitalized, theDates: weekRange, theType: deletingObject.type)
                self.scheduleArray.removeObject(at: (indexPath as NSIndexPath).row)
                tableView.reloadData()
                
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "reason"
                textField.keyboardType = .default
                reason = textField
            })
            alert.addAction(confirmCancel)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        var returnValue : String?
        switch openCloseSegControl.selectedSegmentIndex {
        case 0: returnValue = "Cancel Opening"
        case 1: returnValue = "Cancel Closing"
        default: break
        }
        
        return returnValue!
    }
    @IBAction func segToAdd(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Type?", message: "Is this an opening or closing?", preferredStyle: .alert)
        let storyboard = UIStoryboard(name: "Schedule", bundle: nil)
        
        let openingButton = UIAlertAction(title: "Opening", style: .default) { (action) -> Void in
            AddNewScheduleObjects.isOpening = true
            let VC = storyboard.instantiateViewController(withIdentifier: "addEditSche")
            self.present(VC, animated: true, completion: nil)
        }
        let closingButton = UIAlertAction(title: "Closing", style: .default) { (ACTION) -> Void in
            AddNewScheduleObjects.isOpening = false
            let VC = storyboard.instantiateViewController(withIdentifier: "addEditSche")
            self.present(VC, animated: true, completion: nil)
        }
        
        alert.addAction(openingButton)
        alert.addAction(closingButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayConfirmed() {
        let alert = UIAlertController(title: "Confirmed", message: "The POC has been confirmed", preferredStyle: .alert)
        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ScheduleTableViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.scheduleArray.removeAllObjects()
        self.scheduleQuery()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            scheduleArray.removeAllObjects()
            let query : PFQuery = PFQuery(className: "Schedule")
            query.whereKey("isActive", equalTo: true)
            query.whereKey("type", equalTo: filterOption)
            query.order(byAscending: "weekStart")
            query.whereKey("customerName", contains: searchBar.text!.capitalized)
            query.findObjectsInBackground { (scheduleObjects :[PFObject]?, error: Error?) -> Void in
                if error == nil {
                    self.scheduleArray.removeAllObjects()
                    for object in scheduleObjects! {
                        self.scheduleArray.add(object)
                    }
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = IndexSet(integersIn: range.toRange() ?? 0..<0)
                    self.tableView.reloadSections(sections, with: .automatic)
                }
            }
            if (self.refreshControl!.isRefreshing) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.scheduleArray.removeAllObjects()
            self.scheduleQuery()
        }
    }
}
