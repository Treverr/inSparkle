 //
//  RunTimeReportAllTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/7/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class RunTimeReportAllTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate  {
    
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "All Employees"
        
        self.startDateLabel.text = "select"
        self.endDateLabel.text = "select"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateStartDateLabel", name: "updateStart", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEndDateLabel", name: "updateEnd", object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateStart", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateEnd", object: nil)
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // First Section
        if indexPath.section == 0 {
            // First Cell
            if indexPath.row == 0 {
                
                displayPopover("CalendarDatePicker", indexPath: indexPath)
                
                TimeClockReportAllEmployee.startEnd = "start"
            }
            
            if indexPath.row == 1 {
                
                displayPopover("CalendarDatePicker", indexPath: indexPath)
                
                TimeClockReportAllEmployee.startEnd = "end"
                
            }
        }
    }
    
    func displayPopover(vcID : String, indexPath : NSIndexPath) {
        let storyboard = UIStoryboard(name: "TimeClockReport", bundle: nil)
        let x = self.view.center
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = storyboard.instantiateViewControllerWithIdentifier(vcID)
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRectMake((x.x - 25), x.y, 0, 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func updateStartDateLabel() {
        self.startDateLabel.text = TimeClockReportAllEmployee.selectedStartDate
    }
    
    func updateEndDateLabel() {
        self.endDateLabel.text = TimeClockReportAllEmployee.selectedEndDate
    }
    
    @IBAction func runReportButton(sender: AnyObject) {
        
        let overlay : UIView = UIView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.view.addSubview(overlay)
        
        let activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityMonitor.alpha = 1.0
        activityMonitor.center = self.view.center
        activityMonitor.hidesWhenStopped = true
        self.view.addSubview(activityMonitor)
        activityMonitor.startAnimating()
        
        let startDateString = startDateLabel.text
        let endDateString = endDateLabel.text
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let startDate : NSDate = formatter.dateFromString(startDateString!)!
        var endDate : NSDate = formatter.dateFromString(endDateString!)!
        
        let cal : NSCalendar = NSCalendar.currentCalendar()
        endDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: endDate, options: NSCalendarOptions(rawValue: 0))!
        print(endDate)
        
        getEmployees(startDate, endDate: endDate)
        
    }
    
    var employeeArray = [Employee]()
    
    func getEmployees(startDate : NSDate, endDate : NSDate) {
        let query = Employee.query()
        query?.findObjectsInBackgroundWithBlock({ (employees:[PFObject]?, error:NSError?) -> Void in
            if error == nil && employees?.count > 0 {
                for employee in employees! {
                    self.employeeArray.append(employee as! Employee)
                    
                    if self.employeeArray.count == employees?.count {
                        for emp in self.employeeArray {
                            self.getTimeCardForEachEmployee(emp, startDate: startDate, endDate: endDate)
                        }
                    }
                }
                print(self.employeeArray)
            }
        })
    }
    
    var csvPunches : String = "Employee,TimePunchedIn,TimePunchedOut,TotalTime\n"
    var expectedPunches = 0
    var returnedPunches = 0
    var error = NSErrorPointer()
    
    func getTimeCardForEachEmployee(employee : Employee, startDate : NSDate, endDate : NSDate) {
        var complete : Bool = false
        let timeCardQuery = TimePunchCalcObject.query()
        timeCardQuery?.whereKey("employee", equalTo: employee)
        timeCardQuery?.whereKey("timePunchedIn", greaterThan: startDate)
        timeCardQuery?.whereKey("timePunchedOut", lessThan: endDate)
        expectedPunches = expectedPunches + (timeCardQuery?.countObjects(error))!
        print(expectedPunches)
        timeCardQuery?.findObjectsInBackgroundWithBlock({ (punches : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                
                var totalForEmp : Double! = 0
                
                for punch in punches! {
                    let thePunch = punch as! TimePunchCalcObject
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .MediumStyle
                    formatter.timeStyle = .ShortStyle
                    
                    let employeeName = "\(employee.firstName) \(employee.lastName)"
                    var timePunchedIn = formatter.stringFromDate(thePunch.timePunchedIn)
                    timePunchedIn = timePunchedIn.stringByReplacingOccurrencesOfString(",", withString: " ")
                    var timePunchedOut = formatter.stringFromDate(thePunch.timePunchedOut)
                    timePunchedOut = timePunchedOut.stringByReplacingOccurrencesOfString(",", withString: " ")
                    let totalTime = "\(thePunch.totalTime)"
                    let theTotal = thePunch.totalTime
                    
                    totalForEmp = totalForEmp + theTotal
                    print(totalForEmp)
                    
                    self.csvPunches = self.csvPunches + "\(employeeName),\(timePunchedIn),\(timePunchedOut),\(totalTime)\n"
                    self.returnedPunches = self.returnedPunches + 1
                }
                
                if (self.expectedPunches == 0) && (self.returnedPunches == 0) {
                    
                    let alert = UIAlertController(title: "Error", message: "The report retuned 0 punches, please check your criteria and try again.", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                
                if totalForEmp != 0 {
                    self.csvPunches = self.csvPunches + ",,TOTAL:,\(totalForEmp)\n" + ",,,\n"
                    
                    print(self.expectedPunches)
                    print(self.returnedPunches)
                    print(self.expectedPunches - self.returnedPunches)
            
                    if self.expectedPunches - self.returnedPunches == 0 {
                        print(self.csvPunches)
                        self.shareTime()
                    }
                }
            }
        })
    }
    
    func shareTime() {
        
        let textToShare = NSMutableString()
        textToShare.appendFormat("%@\r", self.csvPunches)
        print("Time to Share: \(textToShare)")
        
        let data = textToShare.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        saveCSV(textToShare)
        
    }
    
    func sheet(whatToShare : AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [whatToShare], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    var docController: UIDocumentInteractionController?
    
    func saveCSV(whatToSave : NSMutableString) {
        let x = self.view.center
        let docs = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0] as! String
        let writePath = docs.stringByAppendingString("TimeCardReport.csv")
        do {
            try whatToSave.writeToFile(writePath, atomically: true, encoding: NSUTF8StringEncoding)
            print("Wrote File")
            print(writePath)
        } catch {
            
        }
        docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: writePath))
        docController!.delegate = self
        docController!.presentPreviewAnimated(true)
    }
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        var viewController: UIViewController = UIViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
        return viewController
    }
    
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}