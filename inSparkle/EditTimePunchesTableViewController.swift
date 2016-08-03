//
//  EditTimePunchesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/9/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class EditTimePunchesTableViewController: UITableViewController {
    
    var punchArray = [PFObject]()
    var theEmployee : Employee!
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    var cellCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: "NotifyEditTableViewToRefresh", object: nil)
        
        theEmployee = AddEditEmpTimeCard.employeeEditingObject
        
        getEmployeeExisitngPunches(theEmployee)
        
        self.navigationController?.navigationBar.barTintColor = Colors.groupGrey
        
    }
    
    func getEmployeeExisitngPunches(emp : Employee) {
        let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.tableView, navController: self.navigationController!)
        loadingUI = returnUI
        loadingUI.frame = CGRectMake(loadingBackground.frame.width, loadingBackground.frame.height, 100, 100)
        loadingUI.center = loadingBackground.center
        loadingBackground = returnBG
        
        let query = TimeClockPunchObj.query()
        query?.whereKey("employee", equalTo: emp)
        query?.orderByDescending("timePunched")
        query?.findObjectsInBackgroundWithBlock({ (thePunches : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                print(thePunches?.count)
                for punch in thePunches! {
                    print(punch)
                    if punch.valueForKey("relatedTimeCalc") == nil {
                        self.punchArray.append(punch as! TimeClockPunchObj)
                    } else {
                        let timeObj = punch.objectForKey("relatedTimeCalc") as! TimePunchCalcObject
                        do {
                            try timeObj.fetchIfNeeded()
                        } catch {
                            
                        }
                        print(timeObj)
                        if self.punchArray.last?.objectId == timeObj.objectId {
                            
                        } else {
                            self.punchArray.append(timeObj)
                        }
                    }
                    self.tableView.reloadData()
                    self.loadingUI.stopAnimation()
                    self.loadingBackground.removeFromSuperview()
                    print(self.punchArray.count)
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("punchCell")
        var theText = ""
        var thePunchForCell = punchArray[indexPath.row]
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        var punchIn = ""
        var punchOut = ""
        var hours = ""
        
        let description = thePunchForCell.description
        
        if !description.containsString("TimePunchTimeCalculations")  {
            let punchObj = thePunchForCell as! TimeClockPunchObj
            punchObj.fetchIfNeededInBackgroundWithBlock({ (obj : PFObject?, error : NSError?) -> Void in
                if error == nil && obj != nil {
                    if punchObj.punchOutIn == "in" {
                        let punchIn = formatter.stringFromDate(punchObj.timePunched)
                        theText = "In: \(punchIn) Out : N/A"
                    }
                    if punchObj.punchOutIn == "out" {
                        let punchOut = formatter.stringFromDate(punchObj.timePunched)
                        theText = "In: N/A Out: \(punchOut)"
                    }
                }
            })
        } else {
            let calcObj = thePunchForCell as! TimePunchCalcObject
            calcObj.fetchIfNeededInBackgroundWithBlock({ (obj : PFObject?, error : NSError?) -> Void in
                if error == nil && obj != nil {
                    punchIn = formatter.stringFromDate(calcObj.timePunchedIn)
                    punchOut = formatter.stringFromDate(calcObj.timePunchedOut)
                    theText = "In: \(punchIn) Out: \(punchOut)"
                }
            })
            
        }
        
        cell?.textLabel?.text = theText
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(punchArray.count)
        return punchArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thePunchObj = self.punchArray[indexPath.row]
        
        let description = thePunchObj.description
        
        if !description.containsString("TimePunchTimeCalculations") {
            let punchPunch = thePunchObj as! TimeClockPunchObj
            if punchPunch.punchOutIn == "in" {
                EditPunch.inTime = punchPunch.timePunched
            }
            if punchPunch.punchOutIn == "out" {
                EditPunch.outTime = punchPunch.timePunched
            }
        } else {
            let punchPunch = thePunchObj as! TimePunchCalcObject
            EditPunch.inTime = punchPunch.timePunchedIn
            EditPunch.outTime = punchPunch.timePunchedOut
            EditPunch.hours = punchPunch.totalTime
        }
        
        EditPunch.timeObj = thePunchObj
        
    }
    
    func refreshTable() {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.punchArray.removeAll()
            self.getEmployeeExisitngPunches(self.theEmployee)
            self.tableView.reloadData()
        }
    }
}
