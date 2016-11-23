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
    var currentSubscribed : PFQuery<PFObject>!
    
    var addButton : UIBarButtonItem!
    var refreshButton : UIBarButtonItem!
    
    var QuckActionsVC : QuickActionsMasterViewController!
    
    @IBOutlet var inboxSentSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StaticViews.messageTableView = self
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.size.height), animated: false)
        
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
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return theMesages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessagesMainTableViewCell
        if theMesages.count > 0 {
            let name = theMesages[(indexPath as NSIndexPath).row].messageFromName
            let date = theMesages[(indexPath as NSIndexPath).row].dateEntered
            let status = theMesages[(indexPath as NSIndexPath).row].status
            let statusTime = theMesages[(indexPath as NSIndexPath).row].statusTime
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.rightBarButtonItems = nil
        
        if PFUser.current() != nil && PFUser.current()?.sessionToken != nil {
            self.refresh()
        } else {
            
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
        
        if PFUser.current()?.object(forKey: "employee") != nil {
            
            do {
                try StaticEmployees.Tom = Employee.query()?.getObjectWithId("hNxAOyqKVy") as! Employee
            } catch {
                // TODO: Handle Error
            }
            
            let emp = PFUser.current()?.object(forKey: "employee") as! Employee
            emp.fetchInBackground()
            let selectedSeg = inboxSentSegControl.selectedSegmentIndex
            let query = Messages.query()
            let employeeObj = PFUser.current()?.object(forKey: "employee") as! Employee
            let currentUser = PFUser.current()
            employeeObj.fetchIfNeededInBackground()
            
            switch selectedSeg {
            case 0:
                query?.whereKey("recipient", equalTo: employeeObj)
                query?.order(byDescending: "dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            case 1:
                query?.whereKey("signed", equalTo: currentUser!)
                query?.order(byDescending: "dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            case 2:
                query?.whereKey("recipient", equalTo: StaticEmployees.Tom)
                query?.order(byDescending: "dateTimeMessage")
                query?.includeKey("recipient")
                query?.includeKey("signed")
            default: break
            }
            
            query?.findObjectsInBackground(block: { (messages : [PFObject]?, error: Error?) -> Void in
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
    
    var client : Client!
    
    func subscribeToUpdates(_ query : PFQuery<PFObject>) {
        if currentSubscribed != nil {
            Client().unsubscribe(self.currentSubscribed)
        }
        self.currentSubscribed = query
        self.liveSubscription = client.subscribe(query as! PFQuery<Messages>)
            
        self.liveSubscription
            .handle(Event.created) {_, item in
                self.handleCreatedEvent(item)
            }
            .handle(Event.updated) {_, item in
                self.handleUpdatedEvent(item)
            }
            .handle(Event.deleted) {_, item in
                self.handleDeletedEvent(item)
        }
        self.currentSubscribed = query
        
    }
    
    func handleCreatedEvent(_ item : Messages) {
        self.theMesages.insert(item, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! MessagesMainTableViewCell
        let name = theMesages[(indexPath as NSIndexPath).row].messageFromName
        let date = theMesages[(indexPath as NSIndexPath).row].dateEntered
        let status = theMesages[(indexPath as NSIndexPath).row].status
        let statusTime = theMesages[(indexPath as NSIndexPath).row].statusTime
        var unread : Bool!
        if status == "Unread" {
            unread = true
        } else {
            unread = false
        }
        
        cell.configureCell(name, date: date, messageStatus: status, statusTime: statusTime, unread: unread)
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func handleUpdatedEvent(_ item : Messages) {
        
    }
    
    func handleDeletedEvent(_ item : Messages) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        print(self.tableView.backgroundView)
        
        if sentFilter {
            self.searchBar.isHidden = false
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        } else {
            if PFUser.current() != nil && EmployeeData.universalEmployee != nil {
                if EmployeeData.universalEmployee.messages {
                    return 1
                } else {
                    self.searchBar.isHidden = true
                    let messageLabel : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                    messageLabel.text = "Access Denied" + "\n\nYou do not have access to view messages."
                    messageLabel.textColor = UIColor.black
                    messageLabel.numberOfLines = 0
                    messageLabel.textAlignment = .center
                    messageLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
                    messageLabel.sizeToFit()
                    
                    self.tableView.backgroundView = messageLabel
                    self.tableView.separatorStyle = .none
                }
            }
            return 0
        }
        
    }
    
    
    @IBAction func unwindToMessageList(_ segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func manualRefresh(_ sender: AnyObject) {
        self.refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ViewEditMessage" {
            let dest = segue.destination as! ComposeMessageTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let selectMessage = theMesages[(indexPath! as NSIndexPath).row]
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
    
    @IBAction func inboxSentSegmentedControl(_ sender: AnyObject) {
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.theMesages.removeAll()
        self.getEmpMessagesFromParse()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.theMesages.removeAll()
        if !searchBar.text!.isEmpty {
            if PFUser.current()?.object(forKey: "employee") != nil {
                let emp = PFUser.current()?.object(forKey: "employee") as! Employee
                if emp.messages {
                    let selectedSeg = inboxSentSegControl.selectedSegmentIndex
                    let query = Messages.query()
                    let employeeObj = PFUser.current()?.object(forKey: "employee") as! Employee
                    let currentUser = PFUser.current()
                    employeeObj.fetchIfNeededInBackground()
                    
                    switch selectedSeg {
                    case 0:
                        query?.whereKey("recipient", equalTo: employeeObj)
                        query?.whereKey("messageFromName", contains: searchBar.text!)
                        query?.order(byDescending: "dateTimeMessage")
                    case 1:
                        query?.whereKey("signed", equalTo: currentUser!)
                        query?.whereKey("messageFromName", contains: searchBar.text!)
                        query?.order(byDescending: "dateTimeMessage")
                    case 2:
                        query?.whereKey("recipient", equalTo: StaticEmployees.Tom)
                        query?.whereKey("messageFromName", contains: searchBar.text!)
                        query?.order(byDescending: "dateTimeMessage")
                    default: break
                    }
                    
                    query?.findObjectsInBackground(block: { (messages : [PFObject]?, error: Error?) -> Void in
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
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text!.isEmpty {
            self.theMesages.removeAll()
            self.getEmpMessagesFromParse()
        }
    }
    
}
