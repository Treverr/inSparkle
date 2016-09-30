//
//  MessagesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/23/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import NVActivityIndicatorView

class MessagesTableViewController: UITableViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    var msgTblViewController : UIViewController?
    
    var theMesages = [Messages]()
    var deepLink = false
    var sentFilter : Bool = false
    
    var liveSubscription : Subscription<Messages>!
    var currentSubscribed : PFQuery!
    
    var addButton : UIBarButtonItem!
    var refreshButton : UIBarButtonItem!
    
    var QuckActionsVC : QuickActionsMasterViewController!
    
    @IBOutlet var inboxSentSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticViews.messageTableView = self
        
        self.tableView.setContentOffset(CGPointMake(0, searchBar.frame.size.height), animated: false)
        
        searchBar.delegate = self
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        msgTblViewController = self.navigationController?.viewControllers.last
        
        self.addButton = self.navigationItem.rightBarButtonItems?.last
        self.refreshButton = self.navigationItem.rightBarButtonItems?.first
        self.navigationItem.rightBarButtonItem = nil
        
        if StaticViews.masterView != nil {
            self.QuckActionsVC = StaticViews.masterView.childViewControllers.first?.childViewControllers.first as! QuickActionsMasterViewController
        }
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return theMesages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesMainTableViewCell
        if theMesages.count > 0 {
            let name = theMesages[indexPath.row].messageFromName
            let date = theMesages[indexPath.row].dateEntered
            let status = theMesages[indexPath.row].status
            let statusTime = theMesages[indexPath.row].statusTime
            var unread : Bool!
            if status == "Unread" {
                unread = true
            } else {
                unread = false
            }
            
            cell.configureCell(name, date: date, messageStatus: status, statusTime: statusTime, unread: unread)
        }
        
        return cell
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.rightBarButtonItems = nil
        
        PFSession.getCurrentSessionInBackgroundWithBlock { (session : PFSession?, error : NSError?) in
            if error != nil {
                PFUser.logOut()
                let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                let currentUser : PFUser?
                
                currentUser = PFUser.currentUser()
                let currentSession = PFUser.currentUser()?.sessionToken
                
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
                
                if currentUser != nil && currentSession != nil {
                    self.refresh()
                }
                
            }
        }
    }
    
    func refresh() {
        self.navigationItem.rightBarButtonItems = nil
        self.theMesages.removeAll()
        self.tableView.reloadData()
        getEmpMessagesFromParse()
        print(self.navigationController?.viewControllers.last)
    }
    
    func getEmpMessagesFromParse() {
        
        if PFUser.currentUser()?.objectForKey("employee") != nil {
            
            do {
                try StaticEmployees.Tom = Employee.query()?.getObjectWithId("hNxAOyqKVy") as! Employee
            } catch {
                // TODO: Handle Error
            }
            
            let emp = PFUser.currentUser()?.objectForKey("employee") as! Employee
            emp.fetchInBackground()
            let selectedSeg = inboxSentSegControl.selectedSegmentIndex
            let query = Messages.query()
            let employeeObj = PFUser.currentUser()?.objectForKey("employee") as! Employee
            let currentUser = PFUser.currentUser()
            employeeObj.fetchIfNeededInBackground()
            
            switch selectedSeg {
            case 0:
                query?.whereKey("recipient", equalTo: employeeObj)
                query?.orderByDescending("dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            case 1:
                query?.whereKey("signed", equalTo: currentUser!)
                query?.orderByDescending("dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            case 2:
                query?.whereKey("recipient", equalTo: StaticEmployees.Tom)
                query?.orderByDescending("dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            default: break
            }
            
            query?.findObjectsInBackgroundWithBlock({ (messages : [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    for msg in messages! {
                        self.theMesages.append(msg as! Messages)
                        self.tableView.reloadData()
                    }
                    //                    self.subscribeToUpdates(query!)
                    self.navigationItem.rightBarButtonItems = [self.refreshButton, self.addButton]
                }
            })
        }
    }
    
    func subscribeToUpdates(query : PFQuery) {
        if currentSubscribed != nil {
            Client().unsubscribe(self.currentSubscribed)
        }
        self.currentSubscribed = query
        self.liveSubscription = query
            .subscribe()
            .handle(Event.Created) {_, item in
                self.handleCreatedEvent(item)
            }
            .handle(Event.Updated) {_, item in
                self.handleUpdatedEvent(item)
            }
            .handle(Event.Deleted) {_, item in
                self.handleDeletedEvent(item)
        }
        self.currentSubscribed = query
        
    }
    
    func handleCreatedEvent(item : Messages) {
        self.theMesages.insert(item, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! MessagesMainTableViewCell
        let name = theMesages[indexPath.row].messageFromName
        let date = theMesages[indexPath.row].dateEntered
        let status = theMesages[indexPath.row].status
        let statusTime = theMesages[indexPath.row].statusTime
        var unread : Bool!
        if status == "Unread" {
            unread = true
        } else {
            unread = false
        }
        
        cell.configureCell(name, date: date, messageStatus: status, statusTime: statusTime, unread: unread)
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func handleUpdatedEvent(item : Messages) {
        
    }
    
    func handleDeletedEvent(item : Messages) {
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        print(self.tableView.backgroundView)
        
        if sentFilter {
            self.searchBar.hidden = false
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
            return 1
        } else {
            if PFUser.currentUser() != nil && EmployeeData.universalEmployee != nil {
                if EmployeeData.universalEmployee.messages {
                    return 1
                } else {
                    self.searchBar.hidden = true
                    let messageLabel : UILabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                    messageLabel.text = "Access Denied" + "\n\nYou do not have access to view messages."
                    messageLabel.textColor = UIColor.blackColor()
                    messageLabel.numberOfLines = 0
                    messageLabel.textAlignment = .Center
                    messageLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
                    messageLabel.sizeToFit()
                    
                    self.tableView.backgroundView = messageLabel
                    self.tableView.separatorStyle = .None
                }
            }
            return 0
        }
        
    }
    
    
    @IBAction func unwindToMessageList(segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func manualRefresh(sender: AnyObject) {
        self.refresh()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ViewEditMessage" {
            let dest = segue.destinationViewController as! ComposeMessageTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let selectMessage = theMesages[indexPath!.row]
            dest.isNewMessage = false
            if inboxSentSegControl.selectedSegmentIndex == 1 {
                dest.isSent = true
            } else {
                dest.isSent = false
            }
            dest.existingMessage = selectMessage
        }
        
    }
    
    var filterKey : PFObject!
    
    @IBAction func inboxSentSegmentedControl(sender: AnyObject) {
        let selected = inboxSentSegControl.selectedSegmentIndex
        
        switch selected {
            
        case 0: sentFilter = false
        case 1: sentFilter = true
        default : break
            
        }
        
        refresh()
    }
    
}

extension MessagesTableViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.theMesages.removeAll()
        self.getEmpMessagesFromParse()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.theMesages.removeAll()
        if !searchBar.text!.isEmpty {
            if PFUser.currentUser()?.objectForKey("employee") != nil {
                let emp = PFUser.currentUser()?.objectForKey("employee") as! Employee
                if emp.messages {
                    let selectedSeg = inboxSentSegControl.selectedSegmentIndex
                    let query = Messages.query()
                    let employeeObj = PFUser.currentUser()?.objectForKey("employee") as! Employee
                    let currentUser = PFUser.currentUser()
                    employeeObj.fetchIfNeededInBackground()
                    
                    switch selectedSeg {
                    case 0:
                        query?.whereKey("recipient", equalTo: employeeObj)
                        query?.whereKey("messageFromName", containsString: searchBar.text!)
                        query?.orderByDescending("dateTimeMessage")
                    case 1:
                        query?.whereKey("signed", equalTo: currentUser!)
                        query?.whereKey("messageFromName", containsString: searchBar.text!)
                        query?.orderByDescending("dateTimeMessage")
                    case 2:
                        query?.whereKey("recipient", equalTo: StaticEmployees.Tom)
                        query?.whereKey("messageFromName", containsString: searchBar.text!)
                        query?.orderByDescending("dateTimeMessage")
                    default: break
                    }
                    
                    query?.findObjectsInBackgroundWithBlock({ (messages : [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            for msg in messages! {
                                self.theMesages.append(msg as! Messages)
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }}
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.theMesages.removeAll()
            self.getEmpMessagesFromParse()
        }
    }
    
}
