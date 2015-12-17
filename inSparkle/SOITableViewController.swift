//
//  SOITableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

protocol sendObjectDelegate
{
    func sendObject(sendingObject : PFObject)
}

class SOITableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var objects : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = Colors.sparkleGreen
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: Selector("refreshInvoked"), forControlEvents: .ValueChanged)
        
        
        setupNavigationbar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "RefreshSOI:", name: "RefreshSOINotification", object: nil)
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        getParseItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        let currentUser : PFUser?
        
        currentUser = PFUser.currentUser()
        
        if (currentUser == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
        
        if (currentUser?.sessionToken == nil) {
            PFUser.logOut()
            let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteParseObject")
            self.navigationItem.leftBarButtonItem = deleteButton
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "segToAdd")
            self.navigationItem.leftBarButtonItem = addButton
        }
    }
    
    func segToAdd() {
        let sb = UIStoryboard(name: "SOI", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("addToSOINav")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("soiCell") as! SOITableViewCell
        
        let object = objects.objectAtIndex(indexPath.row)
        
        let customerName = object.valueForKey("customerName") as! String
        let date = object.valueForKey("date") as? NSDate
        let location = object.valueForKey("location") as! String
        
        cell.soiCell(customerName, date: date, location: location)
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var objectsToDelete = [NSIndexPath]()
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if tableView.indexPathsForSelectedRows != nil {
            objectsToDelete = tableView.indexPathsForSelectedRows!
            self.objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths(objectsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
                deleteParseObject()
            } else {
                objectsToDelete.append(indexPath)
                objsToDelete.append(self.objects[indexPath.row] as! PFObject)
                self.objects.removeObjectAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths(objectsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
                deleteParseObject()
            }
        }
    }
    
    func getParseItems() {
        let query = PFQuery(className: "SOI")
        query.whereKey("isActive", equalTo: true)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (foundObjects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                var foundObjectsCount = foundObjects!.count
                for object in foundObjects! {
                    self.objects.addObject(object)
                    UIView.transitionWithView(self.tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: { () -> Void in
                        self.tableView.reloadData()
                        }, completion: nil)
                }
                if (foundObjectsCount - self.objects.count) == 0 {
                    if (self.refreshControl!.refreshing) {
                        self.refreshControl?.endRefreshing()
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func deleteParseObject() {
        
        for obj in objsToDelete {
            obj["isActive"] = false
            do {
                try obj.save()
            } catch { }
        }
        self.objects.removeAllObjects()
        getParseItems()
        self.tableView.reloadData()

    }
    
    func RefreshSOI(notification : NSNotification) {
        self.objects.removeAllObjects()
        getParseItems()
        self.tableView.reloadData()
        
        
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    func checkSessionToken() -> Bool {
        return true
    }
    
    func refreshInvoked() {
        refresh()
    }
    
    func refresh() {
        self.objects.removeAllObjects()
        UIView.transitionWithView(self.tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
            }, completion: nil)
        getParseItems()
    }
    
    var objsToDelete = [PFObject]()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing == false {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let object = objects[indexPath.row] as! PFObject
            displayInformation(cell!, object: object)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        if tableView.editing == true {
            let theObject = objects[indexPath.row] as! PFObject
            objsToDelete.append(theObject)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing == true {
            let theObject = objects[indexPath.row] as! PFObject
            let objIndex = self.objsToDelete.indexOf(theObject)
            self.objsToDelete.removeAtIndex(objIndex!)
        }
    }
    
    
    func displayInformation(sender : UITableViewCell, object : PFObject) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailPopover = storyBoard.instantiateViewControllerWithIdentifier("DetailPopViewControllerNav") as! UINavigationController
        detailPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = detailPopover.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        let theSendingObject = object
        DataManager.passingObject = theSendingObject
        presentViewController(detailPopover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}
