//
//  EditExistingTimePunchTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class EditExistingTimePunchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var inTimeLabel   : UILabel!
    @IBOutlet var outTimeLabel  : UILabel!
    @IBOutlet var hoursTimeLabel: UILabel!
    
    var inTimeSet   : Bool = false
    var outTimeSet  : Bool = false
    var hoursSet    : Bool = false
    
    var theTimeObject   : PFObject!
    
    var updatedIn   : NSDate?
    var updatedOut  : NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        if inTimeLabel.text != "N/A" {
            inTimeSet = true
        }
        if outTimeLabel.text != "N/A" {
            outTimeSet = true
        }
        if hoursTimeLabel.text != "N/A" {
            hoursSet = true
        }
        
        if EditPunch.inTime != nil {
            inTimeLabel.text = formatter.stringFromDate(EditPunch.inTime!)
            inTimeLabel.textColor = UIColor.blackColor()
        }
        
        if EditPunch.outTime != nil {
            outTimeLabel.text = formatter.stringFromDate(EditPunch.outTime!)
            outTimeLabel.textColor = UIColor.blackColor()
        }
        
        if EditPunch.hours != nil {
            hoursTimeLabel.text = String(EditPunch.hours!)
            hoursTimeLabel.textColor = UIColor.blackColor()
        }
        
        theTimeObject = EditPunch.timeObj
        
        inTimeLabel.userInteractionEnabled = true
        outTimeLabel.userInteractionEnabled = true
        let updatePunchFromIn : Selector = "updatePunchFromIn"
        let updatePunchFromOut : Selector = "updatePunchFromOut"
        let tapGesture = UITapGestureRecognizer(target: self, action: updatePunchFromIn)
        tapGesture.numberOfTapsRequired = 1
        let tapGesture1 = UITapGestureRecognizer(target: self, action: updatePunchFromOut)
        tapGesture.numberOfTapsRequired = 1
        inTimeLabel.addGestureRecognizer(tapGesture)
        outTimeLabel.addGestureRecognizer(tapGesture1)
        
        self.tableView.allowsSelection = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDateLabel", name: "NotifyDateLabelToUpdate", object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteButton(sender: AnyObject) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this time punch? This cannot be undone.", preferredStyle: .Alert)
        let yesButton = UIAlertAction(title: "Yes", style: .Destructive) { (action) -> Void in
            self.deleteTimePunches()
            self.theTimeObject.deleteInBackground()
            NSNotificationCenter.defaultCenter().postNotificationName("NotifyEditTableViewToRefresh", object: nil)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let noButton = UIAlertAction(title: "No", style: .Default, handler: nil)
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteTimePunches() {
        let query = TimeClockPunchObj.query()
        query?.whereKey("relatedTimeCalc", equalTo: self.theTimeObject)
        query?.findObjectsInBackgroundWithBlock({ (objects : [PFObject]?, error : NSError?) -> Void in
            if objects?.count > 0 {
                for obj in objects! {
                    obj.deleteInBackground()
                }
            }
        })
    }
    
    func pickDate(sender : UILabel!, timeObject : PFObject!) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        
        if sender == inTimeLabel {
            if sender.text != "N/A" {
                EditTimePunchesDatePicker.dateToPass = formatter.dateFromString(inTimeLabel.text!)
                EditTimePunchesDatePicker.sender = sender
            } else {
                EditTimePunchesDatePicker.dateToPass = NSDate()
                EditTimePunchesDatePicker.sender = sender
            }
        }
        if sender == outTimeLabel {
            if sender.text != "N/A" {
                EditTimePunchesDatePicker.dateToPass = formatter.dateFromString(outTimeLabel.text!)
                EditTimePunchesDatePicker.sender = sender
            } else {
                EditTimePunchesDatePicker.dateToPass = NSDate()
                EditTimePunchesDatePicker.sender = sender
            }
        }
        let storyboard = UIStoryboard(name: "TimeCardManagement", bundle: nil)
        let datePopover = storyboard.instantiateViewControllerWithIdentifier("popDatePicker") as UIViewController
        datePopover.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = datePopover.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        presentViewController(datePopover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    var datePickerInDate : NSDate?
    
    func updatePunchFromIn() {
        pickDate(self.inTimeLabel, timeObject: theTimeObject)
    }
    
    func updatePunchFromOut() {
        pickDate(self.outTimeLabel, timeObject: theTimeObject)
    }
    
    var gotOriginalIn   : Bool = false
    var gotOriginalOut  : Bool = false
    
    func updateDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        if EditTimePunchesDatePicker.sender == inTimeLabel {
            inTimeLabel.text = formatter.stringFromDate(EditTimePunchesDatePicker.dateToPass)
            updatedIn = EditTimePunchesDatePicker.dateToPass
            print(theTimeObject.description)
            if theTimeObject.description.containsString("TimeClockPunches") {
                // Do Nothing
            } else {
                if (gotOriginalIn) == false {
                    getOriginalIn()
                }
            }
            
        }
        
        if EditTimePunchesDatePicker.sender == outTimeLabel {
            outTimeLabel.text = formatter.stringFromDate(EditTimePunchesDatePicker.dateToPass)
            updatedOut = EditTimePunchesDatePicker.dateToPass
            if theTimeObject.description.containsString("TimeClockPunches") {
                
            } else {
                if (gotOriginalOut) == false {
                    getOriginalOut()
                }
            }
            
        }
    }
    
    var theOriginalIn   : PFObject?
    var theOriginalOut  : PFObject?
    
    func getOriginalIn() {
        
        let timeTime = theTimeObject as! TimePunchCalcObject
        
        let query = PFQuery(className: "TimeClockPunches")
        query.whereKey("punchOutIn", equalTo: "in")
        query.whereKey("relatedTimeCalc", equalTo: timeTime)
        query.getFirstObjectInBackgroundWithBlock { (timePunch : PFObject?, error : NSError?) -> Void in
            if error == nil && timePunch != nil {
                print(timePunch)
                self.theOriginalIn = timePunch!
                self.gotOriginalIn = true
            }
        }
    }
    
    func getOriginalOut() {
        let timeTime = theTimeObject as! TimePunchCalcObject
        
        let query = PFQuery(className: "TimeClockPunches")
        query.whereKey("punchOutIn", equalTo: "out")
        query.whereKey("relatedTimeCalc", equalTo: timeTime)
        query.getFirstObjectInBackgroundWithBlock { (timePunch : PFObject?, error : NSError?) -> Void in
            if error == nil && timePunch != nil {
                print(timePunch)
                self.theOriginalOut = timePunch!
                self.gotOriginalOut = true
            }
        }
    }
    
    var needsCalc : Bool = false
    var subLunch : Bool = false
    
    @IBAction func updateButton(sender: AnyObject) {
        
        if inTimeLabel.text != "N/A" && outTimeLabel.text != "N/A" {
            needsCalc = true
        }
        
        if (needsCalc) {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d/yy, h:mm a"
            let inDate = formatter.dateFromString(inTimeLabel.text!)!
            let outDate = formatter.dateFromString(outTimeLabel.text!)!
            
            if outDate.timeIntervalSinceDate(inDate) > 0 {
                var minutes = outDate.minutesFrom(inDate)
                didTakeLunch()
                if (subLunch) {
                    minutes = minutes - 20
                }
                print(minutes)
                let hours = String(format: "%.2f", (Double(minutes) / 60.00))
                print(self.theTimeObject)
                
                if self.theTimeObject.description.containsString("TimeClockPunches") {
                    
                    let theEmp = self.theTimeObject.objectForKey("employee") as! Employee
                    
                    let newCalc = TimePunchCalcObject()
                    newCalc.timePunchedIn = inDate
                    newCalc.timePunchedOut = outDate
                    newCalc.totalTime = Double(hours)!
                    newCalc.employee = theEmp
                    newCalc.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                        if (success) {
                            let updateTimeObject = self.theTimeObject as! TimeClockPunchObj
                            if updateTimeObject.punchOutIn == "in" {
                                let newPunch = TimeClockPunchObj()
                                newPunch.employee = theEmp
                                newPunch.punchOutIn = "out"
                                newPunch.timePunched = self.updatedOut!
                                newPunch.relatedTimeCalc = newCalc
                                newPunch.saveInBackground()
                            }
                            if updateTimeObject.punchOutIn == "out" {
                                let newPunch = TimeClockPunchObj()
                                newPunch.employee = theEmp
                                newPunch.punchOutIn = "in"
                                newPunch.timePunched = self.updatedIn!
                                newPunch.relatedTimeCalc = newCalc
                                newPunch.saveInBackground()
                            }
                            updateTimeObject.relatedTimeCalc = newCalc
                            updateTimeObject.saveInBackground()
                        }
                    })
                    
                } else {
                    let timeClac = self.theTimeObject as! TimePunchCalcObject
                
                
                
                if updatedIn != nil {
                    timeClac.timePunchedIn = updatedIn!
                    if self.theOriginalIn != nil {
                        let origIn = self.theOriginalIn as! TimeClockPunchObj
                        origIn.timePunched = self.updatedIn!
                        origIn.saveInBackground()
                    }
                }
                if updatedOut != nil {
                    timeClac.timePunchedOut = updatedOut!
                    if self.theOriginalOut != nil {
                        let origOut = self.theOriginalOut as! TimeClockPunchObj
                        origOut.timePunched = self.updatedOut!
                        origOut.saveInBackground()
                    }
                }

                timeClac.totalTime = Double(hours)!
                print(timeClac)
                timeClac.saveInBackground()
                self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                
            } else {
               let alert = UIAlertController(title: "Error", message: "Out punch must be greater than the In punch, try again.", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        } else {
            if updatedIn != nil {
                if self.theTimeObject != nil {
                    let origIn = self.theTimeObject as! TimeClockPunchObj
                    origIn.timePunched = self.updatedIn!
                    origIn.saveInBackground()
                }
            }
            if updatedOut != nil {
                if self.theTimeObject != nil {
                    let origOut = self.theTimeObject as! TimeClockPunchObj
                    origOut.timePunched = self.updatedOut!
                    origOut.saveInBackground()
                }
            }
        }
        
    }
    
    func didTakeLunch() {
        let alert = UIAlertController(title: "Subtract Lunch?", message: nil, preferredStyle: .Alert)
        let yesButton = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            self.subLunch = true
        }
        let noButton = UIAlertAction(title: "No", style: .Default, handler: nil)
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
}
