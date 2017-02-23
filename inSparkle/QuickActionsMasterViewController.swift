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
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
            self.getNumPOCThisWeek()
        }
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
            self.getNextAvailOpening()
        }
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
            self.getNextAvailClosing()
        }
        
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
        
        self.thisWeekPOCNumber.text = "0"
        self.openWorkOrdersNumber.text = "0"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shouldShowHideMaster(_ shouldShow : Bool) {
        if !shouldShow {
            UIView.animate(withDuration: 0.25, animations: {
                self.splitViewController?.preferredDisplayMode = .primaryHidden
                self.isShowingMaster = false
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.splitViewController?.preferredDisplayMode = .automatic
                self.isShowingMaster = true
            })
        }
    }
    
    func selectedAction(_ view : UIView, label : UILabel) {
        view.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.groupTableViewBackground
        
        GlobalFunctions().delay(0.01) {
            label.textColor = self.tintColor
            view.backgroundColor = UIColor.white
        }
    }
    
    func newMessageAction() {
        selectedAction(self.newMessageView, label: self.newMessageButton)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewController(withIdentifier: "composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]
        let tabBar = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.last as! UITabBarController
        let selected = tabBar.selectedIndex
        let vc = UIApplication.shared.keyWindow!.rootViewController!
        nav.modalPresentationStyle = .formSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.present(nav, animated: true, completion: nil)
    }
    
    func newMessageToTom() {
        selectedAction(self.newMessageToTomView, label: self.newMessageToTomLabel)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewController(withIdentifier: "composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]
        
        composeView.selectedEmployee = StaticEmployees.Tom
        MessagesDataObjects.selectedEmp = StaticEmployees.Tom
        composeView.isNewMessage = true
        
        let tabBar = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.last as! UITabBarController
        let selected = tabBar.selectedIndex
        
        let vc = tabBar.childViewControllers[selected] as! UINavigationController
        nav.modalPresentationStyle = .formSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.childViewControllers.first?.present(nav, animated: true, completion: nil)
        
    }
    
    var openWorkOrdersLive : Subscription<WorkOrders>!
    var myClient : Client!
    
    func getOpenWorkOrders() {
        let statuses = ["New", "In Progress", "On Hold", "Assigned", "Ready To Bill"]
        let query = WorkOrders.query()!
        query.whereKey("status", containedIn: statuses)
        query.countObjectsInBackground { (number : Int32, error : Error?) in
            if error == nil {
                self.openWorkOrdersNumber.text = String(number)
                
                if self.openWorkOrdersLive == nil {
                    
                    self.myClient = Client()
                    
                    self.openWorkOrdersLive = self.myClient.subscribe(query as! PFQuery<WorkOrders>)
                    
                    self.openWorkOrdersLive
                        .handle(Event.created) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.updated) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.deleted) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.entered) {_, item in
                            self.getOpenWorkOrders()
                        }
                        .handle(Event.left) {_, item in
                            self.getOpenWorkOrders()
                    }
                }
            }
        }
    }
    
    
    func getNumPOCThisWeek() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        var startOfWeek : Date = Date()
        var interval : TimeInterval = TimeInterval()
        calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: Date())
        
        //        let weekObj : WeekList!
        let query = WeekList.query()!
        query.whereKey("weekStart", equalTo: startOfWeek)
        do {
            let weekObj = try query.getFirstObject() as! WeekList
            print(weekObj)
            
            let weekNumber = ScheduleObject.query()!
            weekNumber.whereKey("weekObj", equalTo: weekObj)
            weekNumber.countObjectsInBackground(block: { (counted : Int32, error : Error?) in
                self.thisWeekPOCNumber.text = String(counted)
                //                weekNumber.subscribe()
                //                    .handle(Event.Created) {_, item in
                //                        self.getNumPOCThisWeek()
                //                    }
                //                    .handle(Event.Updated) {_, item in
                //                        self.getNumPOCThisWeek()
                //                    }
                //                    .handle(Event.Deleted) {_, item in
                //                        self.getNumPOCThisWeek()
                //                    }
                //                    .handle(Event.Entered) {_, item in
                //                        self.getNumPOCThisWeek()
                //                    }
                //                    .handle(Event.Left) {_, item in
                //                        self.getNumPOCThisWeek()
                //                }
            })
        } catch {
            print(error)
        }
    }
    
    func getNextAvailOpening() {
        let query = WeekList.query()!
        query.whereKey("weekEnd", greaterThanOrEqualTo: Date())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: true)
        query.getFirstObjectInBackground { (firstWeek : PFObject?, error : Error?) in
            if error == nil {
                if firstWeek != nil {
                    
                    let week = firstWeek as! WeekList
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    var startWeek = dateFormatter.string(from: week.weekStart)
                    let endRange = startWeek.endIndex
                    let startRange = startWeek.characters.index(startWeek.endIndex, offsetBy: -6)
                    
                    startWeek.removeSubrange(startRange..<endRange)
                    
                    var endWeek = dateFormatter.string(from: week.weekEnd)
                    endWeek.removeSubrange(startRange..<endRange)
                    
                    self.nextAvailOpeningWeeksLabel.text = startWeek + " - " + endWeek
                    
                    //                    query.subscribe()
                    //                        .handle(Event.Created) {_, item in
                    //                            self.getNextAvailOpening()
                    //                        }
                    //                        .handle(Event.Updated) {_, item in
                    //                            self.getNextAvailOpening()
                    //                        }
                    //                        .handle(Event.Deleted) {_, item in
                    //                            self.getNextAvailOpening()
                    //                        }
                    //                        .handle(Event.Entered) {_, item in
                    //                            self.getNextAvailOpening()
                    //                        }
                    //                        .handle(Event.Left) {_, item in
                    //                            self.getNextAvailOpening()
                    //                    }
                } else {
                    self.nextAvailOpeningWeeksLabel.text = "N/A"
                }
            }
        }
    }
    
    func getNextAvailClosing() {
        let query = WeekList.query()!
        query.whereKey("weekEnd", greaterThanOrEqualTo: Date())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.whereKey("isOpenWeek", equalTo: false)
        query.getFirstObjectInBackground { (firstWeek : PFObject?, error : Error?) in
            if error == nil {
                if firstWeek != nil {
                    let week = firstWeek as! WeekList
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    var startWeek = dateFormatter.string(from: week.weekStart)
                    let endRange = startWeek.endIndex
                    let startRange = startWeek.characters.index(startWeek.endIndex, offsetBy: -6)
                    
                    startWeek.removeSubrange(startRange..<endRange)
                    
                    var endWeek = dateFormatter.string(from: week.weekEnd)
                    let endWeekStartRange = endWeek.characters.index(endWeek.endIndex, offsetBy: -6)
                    let endWeekEndRanges = endWeek.endIndex
                    endWeek.removeSubrange(endWeekStartRange..<endWeekEndRanges)
                    
                    self.nextAvailClosingWeeksLabel.text = startWeek + " - " + endWeek
                    
                    //                    query.subscribe()
                    //                        .handle(Event.Created) {_, item in
                    //                            self.getNextAvailClosing()
                    //                        }
                    //                        .handle(Event.Updated) {_, item in
                    //                            self.getNextAvailClosing()
                    //                        }
                    //                        .handle(Event.Deleted) {_, item in
                    //                            self.getNextAvailClosing()
                    //                        }
                    //                        .handle(Event.Entered) {_, item in
                    //                            self.getNextAvailClosing()
                    //                        }
                    //                        .handle(Event.Left) {_, item in
                    //                            self.getNextAvailClosing()
                    //                    }
                } else {
                    self.nextAvailClosingWeeksLabel.text = "N/A"
                }
            } else {
                self.nextAvailClosingWeeksLabel.text = "N/A"
            }
        }
    }
}
