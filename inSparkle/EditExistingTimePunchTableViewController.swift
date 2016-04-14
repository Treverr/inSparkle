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
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
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
                EditTimePunchesDatePicker.dateToPass = nil
                self.dismissViewControllerAnimated(true, completion: nil)
                EditPunch.inTime = nil
                EditPunch.outTime = nil
                EditPunch.hours = nil
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
                    let timeCalcQuery = TimePunchCalcObject.query()
                    timeCalcQuery?.whereKey("objectId", equalTo: self.theTimeObject.objectId!)
                    timeCalcQuery?.findObjectsInBackgroundWithBlock({ (calcs : [PFObject]?, error : NSError?) in
                        PFObject.deleteAllInBackground(calcs)
                    })
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
                EditTimePunchesDatePicker.dateToPass = formatter.dateFromString(sender.text!)
                EditTimePunchesDatePicker.sender = sender
            } else {
                EditTimePunchesDatePicker.dateToPass = NSDate()
                EditTimePunchesDatePicker.sender = sender
            }
        }
        if sender == outTimeLabel {
            if sender.text == "N/A" {
                EditTimePunchesDatePicker.dateToPass = formatter.dateFromString(inTimeLabel.text!)
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
            if theTimeObject != nil {
                if theTimeObject.description.containsString("TimeClockPunches") {
                    // Do Nothing
                } else {
                    if (gotOriginalIn) == false {
                        getOriginalIn()
                    }
                }
            }
        }
        
        if EditTimePunchesDatePicker.sender == outTimeLabel {
            outTimeLabel.text = formatter.stringFromDate(EditTimePunchesDatePicker.dateToPass)
            updatedOut = EditTimePunchesDatePicker.dateToPass
            if theTimeObject != nil {
                if theTimeObject.description.containsString("TimeClockPunches") {
                    
                } else {
                    if (gotOriginalOut) == false {
                        getOriginalOut()
                    }
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
    
    @IBAction func startUpDate(sender : AnyObject) {
        if inTimeLabel.text != "N/A" && outTimeLabel.text != "N/A" {
            needsCalc = true
            updateButton(self)
        } else {
            needsCalc = false
            updateButton(self)
        }
    }
    
    @IBAction func updateButton(sender: AnyObject) {
        
        if (needsCalc) {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d/yy, h:mm a"
            let inDate = formatter.dateFromString(inTimeLabel.text!)!
            let outDate = formatter.dateFromString(outTimeLabel.text!)!
            
            if outDate.timeIntervalSinceDate(inDate) > 0 {
                var minutes = outDate.minutesFrom(inDate)
                if minutes > 240 {
                    minutes = minutes - 20
                }
                let hours = String(format: "%.2f", (Double(minutes) / 60.00))
                
                if self.theTimeObject == nil {
                    
                    let theEmp = AddEditEmpTimeCard.employeeEditingObject
                    
                    let newCalc = TimePunchCalcObject()
                    newCalc.timePunchedIn = inDate
                    newCalc.timePunchedOut = outDate
                    newCalc.totalTime = Double(hours)!
                    newCalc.employee = theEmp
                    newCalc.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        let newPunchIn = TimeClockPunchObj()
                        newPunchIn.employee = theEmp
                        newPunchIn.punchOutIn = "in"
                        newPunchIn.timePunched = inDate
                        newPunchIn.relatedTimeCalc = newCalc
                        newPunchIn.saveInBackgroundWithBlock({ (success: Bool, errro :NSError?) -> Void in
                            if (success) {
                                let newPunchOut = TimeClockPunchObj()
                                newPunchOut.employee = theEmp
                                newPunchOut.punchOutIn = "out"
                                newPunchOut.timePunched = outDate
                                newPunchOut.relatedTimeCalc = newCalc
                                newPunchOut.relatedPunch = newPunchIn
                                newPunchOut.saveInBackgroundWithBlock({ (success: Bool, error:NSError?) -> Void in
                                    if (success) {
                                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC)))
                                        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                                            newPunchIn.relatedPunch = newPunchOut
                                            newPunchIn.saveInBackground()
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    }
                                })
                            }
                        })
                        
                    })
                    
                } else {
                    
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
                                    newPunch.relatedPunch = self.theTimeObject as! TimeClockPunchObj
                                    newPunch.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                                        if success {
                                            updateTimeObject.relatedPunch = newPunch
                                            updateTimeObject.saveInBackground()
                                        }
                                    })
                                }
                                if updateTimeObject.punchOutIn == "out" {
                                    let newPunch = TimeClockPunchObj()
                                    newPunch.employee = theEmp
                                    newPunch.punchOutIn = "in"
                                    newPunch.timePunched = self.updatedIn!
                                    newPunch.relatedTimeCalc = newCalc
                                    newPunch.relatedPunch = self.theTimeObject as! TimeClockPunchObj
                                    newPunch.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                                        if success {
                                            updateTimeObject.relatedPunch = newPunch
                                            updateTimeObject.saveInBackground()
                                        }
                                    })
                                }
                                updateTimeObject.relatedTimeCalc = newCalc
                                print(updateTimeObject)
                                updateTimeObject.saveInBackground()
                                self.dismissViewControllerAnimated(true, completion: { 
                                    NSNotificationCenter.defaultCenter().postNotificationName("NotifyEditTableViewToRefresh", object: nil)
                                })
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
                        NSNotificationCenter.defaultCenter().postNotificationName("NotifyEditTableViewToRefresh", object: nil)
                        
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            EditTimePunchesDatePicker.dateToPass = nil
                            self.dismissViewControllerAnimated(true, completion: nil)
                            EditPunch.inTime = nil
                            EditPunch.outTime = nil
                            EditPunch.hours = nil
                        }
                    }
                }
                
                
            } else {
                let alert = UIAlertController(title: "Error", message: "Out punch must be greater than the In punch, try again.", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        } else {
            
            let theEmp = AddEditEmpTimeCard.employeeEditingObject
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d/yy, h:mm a"
            
            if updatedIn != nil {
                if self.theTimeObject != nil {
                    let origIn = self.theTimeObject as! TimeClockPunchObj
                    origIn.timePunched = self.updatedIn!
                    origIn.saveInBackground()
                    EditPunch.inTime = nil
                    EditPunch.outTime = nil
                    EditPunch.hours = nil
                }
            }
            
            if updatedOut != nil {
                if self.theTimeObject != nil {
                    let origOut = self.theTimeObject as! TimeClockPunchObj
                    origOut.timePunched = self.updatedOut!
                    origOut.saveInBackground()
                    EditPunch.inTime = nil
                    EditPunch.outTime = nil
                    EditPunch.hours = nil
            
                }
            }
            
            if inTimeLabel.text != "N/A" {
                let inDate = formatter.dateFromString(inTimeLabel.text!)!
                let newPunchIn = TimeClockPunchObj()
                newPunchIn.employee = theEmp
                newPunchIn.timePunched = inDate
                newPunchIn.punchOutIn = "in"
                newPunchIn.saveInBackground()
                NSNotificationCenter.defaultCenter().postNotificationName("NotifyEditTableViewToRefresh", object: nil)
                
            }
            
            
            if self.theTimeObject != nil {
                if outTimeLabel.text != "N/A" {
                    if inTimeLabel.text == "N/A" {
                        let alert = UIAlertController(title: "Update In", message: "You should never add just an OUT punch, please adjust an exisitng IN punch.", preferredStyle: .Alert)
                        let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                        alert.addAction(okayButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                        EditPunch.inTime = nil
                        EditPunch.outTime = nil
                        EditPunch.hours = nil
                    }
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("NotifyEditTableViewToRefresh", object: nil)
        }
        
    }
    
    func didTakeLunch() {
        var returns : Bool?
        let alert = UIAlertController(title: "Subtract Lunch?", message: nil, preferredStyle: .Alert)
        let yesButton = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            self.subLunch = true
            self.updateButton(self)
        }
        let noButton = UIAlertAction(title: "No", style: .Default){ (action) -> Void in
            self.subLunch = false
            self.updateButton(self)
        }
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        EditPunch.inTime = nil
        EditPunch.outTime = nil
        EditPunch.hours = nil
        EditPunch.timeObj = nil
        EditTimePunchesDatePicker.dateToPass = nil
        EditTimePunchesDatePicker.sender = nil
    }
}
