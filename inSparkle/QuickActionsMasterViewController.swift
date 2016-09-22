//
//  QuickActionsMasterViewController.swift
//  inSparkle
//
//  Created by Trever on 9/17/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class QuickActionsMasterViewController: UIViewController {
    
    var isShowingMaster = true
    
    // New Message to Tom
    @IBOutlet weak var newMessageToTomView: UIView!
    @IBOutlet weak var newMessageToTomLabel: UILabel!
    
    // New Message
    @IBOutlet weak var newMessageView: UIView!
    @IBOutlet weak var newMessageButton: UILabel!
    
    // Next Available:
    //Opening
    @IBOutlet weak var nextAvailOpeningView: UIView!
    @IBOutlet weak var nextAvailOpeningWeeksLabel: UILabel!
    
    // Closing
    @IBOutlet weak var nextAvailClosingView: UIView!
    @IBOutlet weak var nextAvailClosingWeeksLabel: UILabel!
    
    // Open Work Orders
    @IBOutlet weak var openWorkWordersView: UIView!
    @IBOutlet weak var openWorkOrdersNumber: UILabel!
    
    // This Week POC
    @IBOutlet weak var thisWeekPOCView: UIView!
    @IBOutlet weak var thisWeekPOCNumber: UILabel!
    
    var tintColor : UIColor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getOpenWorkOrders()
        self.getNumPOCThisWeek()
        self.getNextAvailOpening()
        self.getNextAvailClosing()
        
        self.tintColor = self.view.tintColor
        
        newMessageToTomView.layer.cornerRadius = 5
        newMessageView.layer.cornerRadius = 5
        nextAvailOpeningView.layer.cornerRadius = 5
        nextAvailClosingView.layer.cornerRadius = 5
        openWorkWordersView.layer.cornerRadius = 5
        thisWeekPOCView.layer.cornerRadius = 5
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        let newMessageToTom = UITapGestureRecognizer(target: self, action: #selector(QuickActionsMasterViewController.newMessageToTom))
        newMessageToTom.numberOfTapsRequired = 1
        newMessageToTomView.addGestureRecognizer(newMessageToTom)
        
        let newMessageGesture = UITapGestureRecognizer(target: self, action: #selector(self.newMessageAction))
        newMessageGesture.numberOfTapsRequired = 1
        newMessageView.addGestureRecognizer(newMessageGesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shouldShowHideMaster(shouldShow : Bool) {
        if !shouldShow {
            UIView.animateWithDuration(0.25, animations: {
                self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                self.isShowingMaster = false
            })
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.splitViewController?.preferredDisplayMode = .Automatic
                self.isShowingMaster = true
            })
        }
    }
    
    func selectedAction(view : UIView, label : UILabel) {
        view.backgroundColor = UIColor.lightGrayColor()
        label.textColor = UIColor.groupTableViewBackgroundColor()
        
        GlobalFunctions().delay(0.01) {
            label.textColor = self.tintColor
            view.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func newMessageAction() {
        selectedAction(self.newMessageView, label: self.newMessageButton)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewControllerWithIdentifier("composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]
        let tabBar = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.last as! UITabBarController
        let selected = tabBar.selectedIndex
        let vc = tabBar.childViewControllers[selected] as! UINavigationController
        nav.modalPresentationStyle = .FormSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.childViewControllers.first?.presentViewController(nav, animated: true, completion: nil)
    }
    
    func newMessageToTom() {
        selectedAction(self.newMessageToTomView, label: self.newMessageToTomLabel)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewControllerWithIdentifier("composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]
        
        composeView.selectedEmployee = StaticEmployees.Tom
        MessagesDataObjects.selectedEmp = StaticEmployees.Tom
        composeView.isNewMessage = true
        
        let tabBar = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.last as! UITabBarController
        let selected = tabBar.selectedIndex
        
        let vc = tabBar.childViewControllers[selected] as! UINavigationController
        nav.modalPresentationStyle = .FormSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.childViewControllers.first?.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    var openWorkOrdersLive : Subscription<WorkOrders>!
    
    func getOpenWorkOrders() {
        let statuses = ["New", "In Progress", "On Hold", "Assigned", "Ready To Bill"]
        let query = WorkOrders.query()!
        query.whereKey("status", containedIn: statuses)
        query.countObjectsInBackgroundWithBlock { (number : Int32, error : NSError?) in
            if error == nil {
                self.openWorkOrdersNumber.text = String(number)
                
                if self.openWorkOrdersLive == nil {
                    self.openWorkOrdersLive = query
                        .subscribe()
                        .handle(Event.Created) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.Updated) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.Deleted) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.Entered) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.Left) {_, item in
                            self.getOpenWorkOrders()
                    }
                }
            }
        }
    }
    
    
    func getNumPOCThisWeek() {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")!
        var startOfWeek : NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startOfWeek, interval: nil, forDate: NSDate())
        
        //        let weekObj : WeekList!
        let query = WeekList.query()!
        query.whereKey("weekStart", equalTo: startOfWeek!)
        do {
            let weekObj = try query.getFirstObject() as! WeekList
            print(weekObj)
            
            let weekNumber = ScheduleObject.query()!
            weekNumber.whereKey("weekObj", equalTo: weekObj)
            weekNumber.countObjectsInBackgroundWithBlock({ (counted : Int32, error : NSError?) in
                self.thisWeekPOCNumber.text = String(counted)
                weekNumber.subscribe()
                    .handle(Event.Created) {_, item in
                        self.getNumPOCThisWeek()
                    }
                    .handle(Event.Updated) {_, item in
                        self.getNumPOCThisWeek()
                    }
                    .handle(Event.Deleted) {_, item in
                        self.getNumPOCThisWeek()
                    }
                    .handle(Event.Entered) {_, item in
                        self.getNumPOCThisWeek()
                    }
                    .handle(Event.Left) {_, item in
                        self.getNumPOCThisWeek()
                }
            })
        } catch {
            print(error)
        }
    }
    
    func getNextAvailOpening() {
        let query = WeekList.query()!
        query.whereKey("weekEnd", greaterThanOrEqualTo: NSDate())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: true)
        query.getFirstObjectInBackgroundWithBlock { (firstWeek : PFObject?, error : NSError?) in
            if error == nil {
                if firstWeek != nil {
                    let week = firstWeek as! WeekList
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    dateFormatter.timeStyle = .NoStyle
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                    
                    var startWeek = dateFormatter.stringFromDate(week.weekStart)
                    let endRange = startWeek.endIndex
                    let startRange = startWeek.endIndex.advancedBy(-6)
                    
                    startWeek.removeRange(startRange..<endRange)
                    
                    var endWeek = dateFormatter.stringFromDate(week.weekEnd)
                    endWeek.removeRange(startRange..<endRange)
                    
                    self.nextAvailOpeningWeeksLabel.text = startWeek + " - " + endWeek
                    
                    query.subscribe()
                        .handle(Event.Created) {_, item in
                            self.getNextAvailOpening()
                        }
                        .handle(Event.Updated) {_, item in
                            self.getNextAvailOpening()
                        }
                        .handle(Event.Deleted) {_, item in
                            self.getNextAvailOpening()
                        }
                        .handle(Event.Entered) {_, item in
                            self.getNextAvailOpening()
                        }
                        .handle(Event.Left) {_, item in
                            self.getNextAvailOpening()
                    }
                }
            } else {
                self.nextAvailOpeningWeeksLabel.text = "N/A"
            }
        }
    }
    
    func getNextAvailClosing() {
        let query = WeekList.query()!
        query.whereKey("weekEnd", greaterThanOrEqualTo: NSDate())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: false)
        query.getFirstObjectInBackgroundWithBlock { (firstWeek : PFObject?, error : NSError?) in
            if error == nil {
                if firstWeek != nil {
                    let week = firstWeek as! WeekList
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    dateFormatter.timeStyle = .NoStyle
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                    
                    var startWeek = dateFormatter.stringFromDate(week.weekStart)
                    let endRange = startWeek.endIndex
                    let startRange = startWeek.endIndex.advancedBy(-6)
                    
                    startWeek.removeRange(startRange..<endRange)
                    
                    var endWeek = dateFormatter.stringFromDate(week.weekEnd)
                    endWeek.removeRange(startRange..<endRange)
                    
                    self.nextAvailClosingWeeksLabel.text = startWeek + " - " + endWeek
                    
                    query.subscribe()
                        .handle(Event.Created) {_, item in
                            self.getNextAvailClosing()
                        }
                        .handle(Event.Updated) {_, item in
                            self.getNextAvailClosing()
                        }
                        .handle(Event.Deleted) {_, item in
                            self.getNextAvailClosing()
                        }
                        .handle(Event.Entered) {_, item in
                            self.getNextAvailClosing()
                        }
                        .handle(Event.Left) {_, item in
                            self.getNextAvailClosing()
                    }
                }
            } else {
                self.nextAvailOpeningWeeksLabel.text = "N/A"
            }
        }
    }
}
