//
//  EditExistingTimePunchTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EditExistingTimePunchTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var inTimeLabel   : UILabel!
    @IBOutlet var outTimeLabel  : UILabel!
    @IBOutlet var hoursTimeLabel: UILabel!
    
    var inTimeSet   : Bool = false
    var outTimeSet  : Bool = false
    var hoursSet    : Bool = false
    
    var theTimeObject   : PFObject!
    
    var updatedIn   : Date?
    var updatedOut  : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
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
            inTimeLabel.text = formatter.string(from: EditPunch.inTime! as Date)
            inTimeLabel.textColor = UIColor.black
        }
        
        if EditPunch.outTime != nil {
            outTimeLabel.text = formatter.string(from: EditPunch.outTime! as Date)
            outTimeLabel.textColor = UIColor.black
        }
        
        if EditPunch.hours != nil {
            hoursTimeLabel.text = String(EditPunch.hours!)
            hoursTimeLabel.textColor = UIColor.black
        }
        
        theTimeObject = EditPunch.timeObj
        
        inTimeLabel.isUserInteractionEnabled = true
        outTimeLabel.isUserInteractionEnabled = true
        let updatePunchFromIn : Selector = #selector(EditExistingTimePunchTableViewController.updatePunchFromIn)
        let updatePunchFromOut : Selector = #selector(EditExistingTimePunchTableViewController.updatePunchFromOut)
        let tapGesture = UITapGestureRecognizer(target: self, action: updatePunchFromIn)
        tapGesture.numberOfTapsRequired = 1
        let tapGesture1 = UITapGestureRecognizer(target: self, action: updatePunchFromOut)
        tapGesture.numberOfTapsRequired = 1
        inTimeLabel.addGestureRecognizer(tapGesture)
        outTimeLabel.addGestureRecognizer(tapGesture1)
        
        self.tableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditExistingTimePunchTableViewController.updateDateLabel), name: NSNotification.Name(rawValue: "NotifyDateLabelToUpdate"), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteButton(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this time punch? This cannot be undone.", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { (action) -> Void in
            self.deleteTimePunches()
            self.theTimeObject.deleteInBackground()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
            
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                EditTimePunchesDatePicker.dateToPass = nil
                self.dismiss(animated: true, completion: nil)
                EditPunch.inTime = nil
                EditPunch.outTime = nil
                EditPunch.hours = nil
            }
        }
        let noButton = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTimePunches() {
        let query = TimeClockPunchObj.query()
        query?.whereKey("relatedTimeCalc", equalTo: self.theTimeObject)
        query?.findObjectsInBackground(block: { (objects : [PFObject]?, error : Error?) -> Void in
            if objects?.count > 0 {
                for obj in objects! {
                    let timeCalcQuery = TimePunchCalcObject.query()
                    timeCalcQuery?.whereKey("objectId", equalTo: self.theTimeObject.objectId!)
                    timeCalcQuery?.findObjectsInBackground(block: { (calcs : [PFObject]?, error : Error?) in
                        PFObject.deleteAll(inBackground: calcs)
                    })
                    obj.deleteInBackground()
                }
            }
        })
    }
    
    func pickDate(_ sender : UILabel!, timeObject : PFObject!) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy, h:mm a"
        
        if sender == inTimeLabel {
            if sender.text != "N/A" {
                EditTimePunchesDatePicker.dateToPass = formatter.date(from: sender.text!)
                EditTimePunchesDatePicker.sender = sender
            } else {
                EditTimePunchesDatePicker.dateToPass = Date()
                EditTimePunchesDatePicker.sender = sender
            }
        }
        if sender == outTimeLabel {
            if sender.text == "N/A" {
                EditTimePunchesDatePicker.dateToPass = formatter.date(from: inTimeLabel.text!)
                EditTimePunchesDatePicker.sender = sender
            } else {
                EditTimePunchesDatePicker.dateToPass = Date()
                EditTimePunchesDatePicker.sender = sender
            }
        }
        let storyboard = UIStoryboard(name: "TimeCardManagement", bundle: nil)
        let datePopover = storyboard.instantiateViewController(withIdentifier: "popDatePicker") as UIViewController
        datePopover.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = datePopover.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        present(datePopover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    var datePickerInDate : Date?
    
    func updatePunchFromIn() {
        pickDate(self.inTimeLabel, timeObject: theTimeObject)
    }
    
    func updatePunchFromOut() {
        pickDate(self.outTimeLabel, timeObject: theTimeObject)
    }
    
    var gotOriginalIn   : Bool = false
    var gotOriginalOut  : Bool = false
    
    func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if EditTimePunchesDatePicker.sender == inTimeLabel {
            inTimeLabel.text = formatter.string(from: EditTimePunchesDatePicker.dateToPass as Date)
            updatedIn = EditTimePunchesDatePicker.dateToPass as Date?
            if theTimeObject != nil {
                if theTimeObject.description.contains("TimeClockPunches") {
                    // Do Nothing
                } else {
                    if (gotOriginalIn) == false {
                        getOriginalIn()
                    }
                }
            }
        }
        
        if EditTimePunchesDatePicker.sender == outTimeLabel {
            outTimeLabel.text = formatter.string(from: EditTimePunchesDatePicker.dateToPass as Date)
            updatedOut = EditTimePunchesDatePicker.dateToPass as Date?
            if theTimeObject != nil {
                if theTimeObject.description.contains("TimeClockPunches") {
                    
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
        query.getFirstObjectInBackground { (timePunch : PFObject?, error : Error?) -> Void in
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
        query.getFirstObjectInBackground { (timePunch : PFObject?, error : Error?) -> Void in
            if error == nil && timePunch != nil {
                print(timePunch)
                self.theOriginalOut = timePunch!
                self.gotOriginalOut = true
            }
        }
    }
    
    var needsCalc : Bool = false
    var subLunch : Bool = false
    
    @IBAction func startUpDate(_ sender : AnyObject) {
        if inTimeLabel.text != "N/A" && outTimeLabel.text != "N/A" {
            needsCalc = true
            updateButton(self)
        } else {
            needsCalc = false
            updateButton(self)
        }
    }
    
    @IBAction func updateButton(_ sender: AnyObject) {
        
        if (needsCalc) {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yy, h:mm a"
            let inDate = formatter.date(from: inTimeLabel.text!)!
            let outDate = formatter.date(from: outTimeLabel.text!)!
            
            if outDate.timeIntervalSince(inDate) > 0 {
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
                    newCalc.employee = theEmp!
                    newCalc.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                        let newPunchIn = TimeClockPunchObj()
                        newPunchIn.employee = theEmp!
                        newPunchIn.punchOutIn = "in"
                        newPunchIn.timePunched = inDate
                        newPunchIn.relatedTimeCalc = newCalc
                        newPunchIn.saveInBackground(block: { (success: Bool, errro :Error?) -> Void in
                            if (success) {
                                let newPunchOut = TimeClockPunchObj()
                                newPunchOut.employee = theEmp!
                                newPunchOut.punchOutIn = "out"
                                newPunchOut.timePunched = outDate
                                newPunchOut.relatedTimeCalc = newCalc
                                newPunchOut.relatedPunch = newPunchIn
                                newPunchOut.saveInBackground(block: { (success: Bool, error:Error?) -> Void in
                                    if (success) {
                                        let delayTime = DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                                        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { () -> Void in
                                            newPunchIn.relatedPunch = newPunchOut
                                            newPunchIn.saveInBackground()
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                })
                            }
                        })
                        
                    })
                    
                } else {
                    
                    if self.theTimeObject.description.contains("TimeClockPunches") {
                        
                        let theEmp = self.theTimeObject.object(forKey: "employee") as! Employee
                        
                        let newCalc = TimePunchCalcObject()
                        newCalc.timePunchedIn = inDate
                        newCalc.timePunchedOut = outDate
                        newCalc.totalTime = Double(hours)!
                        newCalc.employee = theEmp
                        newCalc.saveInBackground(block: { (success : Bool, error : Error?) -> Void in
                            if (success) {
                                let updateTimeObject = self.theTimeObject as! TimeClockPunchObj
                                if updateTimeObject.punchOutIn == "in" {
                                    let newPunch = TimeClockPunchObj()
                                    newPunch.employee = theEmp
                                    newPunch.punchOutIn = "out"
                                    newPunch.timePunched = self.updatedOut!
                                    newPunch.relatedTimeCalc = newCalc
                                    newPunch.relatedPunch = self.theTimeObject as! TimeClockPunchObj
                                    newPunch.saveInBackground(block: { (success : Bool, error : Error?) in
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
                                    newPunch.saveInBackground(block: { (success : Bool, error : Error?) in
                                        if success {
                                            updateTimeObject.relatedPunch = newPunch
                                            updateTimeObject.saveInBackground()
                                        }
                                    })
                                }
                                updateTimeObject.relatedTimeCalc = newCalc
                                print(updateTimeObject)
                                updateTimeObject.saveInBackground()
                                self.dismiss(animated: true, completion: { 
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
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
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
                        
                        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            EditTimePunchesDatePicker.dateToPass = nil
                            self.dismiss(animated: true, completion: nil)
                            EditPunch.inTime = nil
                            EditPunch.outTime = nil
                            EditPunch.hours = nil
                        }
                    }
                }
                
                
            } else {
                let alert = UIAlertController(title: "Error", message: "Out punch must be greater than the In punch, try again.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            let theEmp = AddEditEmpTimeCard.employeeEditingObject
            let formatter = DateFormatter()
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
                let inDate = formatter.date(from: inTimeLabel.text!)!
                let newPunchIn = TimeClockPunchObj()
                newPunchIn.employee = theEmp!
                newPunchIn.timePunched = inDate
                newPunchIn.punchOutIn = "in"
                newPunchIn.saveInBackground()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
                
            }
            
            
            if self.theTimeObject != nil {
                if outTimeLabel.text != "N/A" {
                    if inTimeLabel.text == "N/A" {
                        let alert = UIAlertController(title: "Update In", message: "You should never add just an OUT punch, please adjust an exisitng IN punch.", preferredStyle: .alert)
                        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alert.addAction(okayButton)
                        self.present(alert, animated: true, completion: nil)
                        EditPunch.inTime = nil
                        EditPunch.outTime = nil
                        EditPunch.hours = nil
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NotifyEditTableViewToRefresh"), object: nil)
        }
        
    }
    
    func didTakeLunch() {
        var returns : Bool?
        let alert = UIAlertController(title: "Subtract Lunch?", message: nil, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            self.subLunch = true
            self.updateButton(self)
        }
        let noButton = UIAlertAction(title: "No", style: .default){ (action) -> Void in
            self.subLunch = false
            self.updateButton(self)
        }
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        EditPunch.inTime = nil
        EditPunch.outTime = nil
        EditPunch.hours = nil
        EditPunch.timeObj = nil
        EditTimePunchesDatePicker.dateToPass = nil
        EditTimePunchesDatePicker.sender = nil
    }
}
