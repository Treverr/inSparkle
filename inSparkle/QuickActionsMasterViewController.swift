//
//  QuickActionsMasterViewController.swift
//  inSparkle
//
//  Created by Trever on 9/17/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class QuickActionsMasterViewController: UIViewController {
    
    var isShowingMaster = true
    
    // New Message to Tom
    @IBOutlet weak var newMessageToTomView: UIView!
    @IBOutlet weak var newMessageToTomLabel: UILabel!
    
    // New Message
    @IBOutlet weak var newMessageView: UIView!
    @IBOutlet weak var newMessageButton: UIButton!
    
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
    
    @IBAction func newMessageAction(sender: AnyObject) {

    }
    
    func newMessageToTom() {
        selectedAction(self.newMessageToTomView, label: self.newMessageToTomLabel)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewControllerWithIdentifier("composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]

        composeView.selectedEmployee = StaticEmployees.Tom
        composeView.isNewMessage = true
        
        let tabBar = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers.last as! UITabBarController
        let selected = tabBar.selectedIndex
        
        let vc = tabBar.childViewControllers[selected] as! UINavigationController
        nav.modalPresentationStyle = .FormSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.childViewControllers.first?.presentViewController(nav, animated: true, completion: nil)
        
    }
}
