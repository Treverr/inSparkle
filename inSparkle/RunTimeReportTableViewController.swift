 //
 //  RunTimeReportAllTableViewController.swift
 //  inSparkle
 //
 //  Created by Trever on 12/7/15.
 //  Copyright © 2015 Sparkle Pools. All rights reserved.
 //
 
 import UIKit
 import Parse
 import NVActivityIndicatorView
 
 class RunTimeReportTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate  {
    
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    
    var detail : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "All Employees"
        
        self.startDateLabel.text = "select"
        self.endDateLabel.text = "select"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RunTimeReportTableViewController.updateStartDateLabel), name: "updateStart", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RunTimeReportTableViewController.updateEndDateLabel), name: "updateEnd", object: nil)
        
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
    
    func swiftActive() {
        
        let (returnUI, returnBG) = GlobalFunctions().loadingAnimation(self.loadingUI, loadingBG: self.loadingBackground, view: self.view, navController: self.navigationController!)
        loadingUI = returnUI
        
        loadingBackground.frame = self.view.frame
        loadingBackground.backgroundColor = UIColor.blackColor()
        
    }
    
    @IBAction func runReportButton(sender: AnyObject) {
        
        performSelectorOnMainThread(#selector(RunTimeReportTableViewController.swiftActive), withObject: nil, waitUntilDone: true)

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
        if !detail {
            csvPunches = "Employee,StandardHours,OvertimeHours,VacationHours,TotalTime\n"
            csvPunches = csvPunches + "Marti Ennis,Salary,-,-,-\n"
            csvPunches = csvPunches + "Tom Sedletzeck,Salary,-,-,-\n"
        }
        var employeeName : String?
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
                var vacationHours : Double = 0.0
                
                for punch in punches! {
                    let thePunch = punch as! TimePunchCalcObject
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = .MediumStyle
                    formatter.timeStyle = .ShortStyle
                    
                    employeeName = "\(employee.firstName) \(employee.lastName)"
                    var timePunchedIn = formatter.stringFromDate(thePunch.timePunchedIn)
                    timePunchedIn = timePunchedIn.stringByReplacingOccurrencesOfString(",", withString: " ")
                    var timePunchedOut = formatter.stringFromDate(thePunch.timePunchedOut)
                    timePunchedOut = timePunchedOut.stringByReplacingOccurrencesOfString(",", withString: " ")
                    let totalTime = "\(thePunch.totalTime)"
                    let theTotal = thePunch.totalTime
                    
                    totalForEmp = totalForEmp + theTotal
                    print(totalForEmp)
                    
                    if self.detail {
                        self.csvPunches = self.csvPunches + "\(employeeName!),\(timePunchedIn),\(timePunchedOut),\(totalTime)\n"
                    }
                    
                    self.returnedPunches = self.returnedPunches + 1
                }
                
                let vacaQuery = VacationTimePunch.query()
                vacaQuery?.whereKey("employee", equalTo: employee)
                vacaQuery?.whereKey("vacationDate", greaterThanOrEqualTo: startDate)
                vacaQuery?.whereKey("vacationDate", lessThanOrEqualTo: endDate)
                do {
                    let vacaObjs = try vacaQuery?.findObjects()
                    if vacaObjs?.count > 0 {
                        self.expectedPunches = self.expectedPunches + vacaObjs!.count
                        for vObj in vacaObjs! {
                            let obj = vObj as! VacationTimePunch
                            vacationHours = vacationHours + obj.vacationHours
                            self.returnedPunches = self.returnedPunches + 1
                        }
                        totalForEmp = totalForEmp + vacationHours
                        
                        if employeeName == nil {
                            employeeName = "\(employee.firstName) \(employee.lastName)"
                        }
                    }
                } catch { }

//                if (self.expectedPunches == 0) && (self.returnedPunches == 0) {
//                    
//                    let alert = UIAlertController(title: "Error", message: "The report retuned 0 punches, please check your criteria and try again.", preferredStyle: .Alert)
//                    let okButton = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
//                        self.dismissViewControllerAnimated(true, completion: nil)
//                    })
//                    alert.addAction(okButton)
//                    self.presentViewController(alert, animated: true, completion: nil)
//                    
//                }
                
                if totalForEmp != 0 {
                    if (self.detail) {
                        self.csvPunches = self.csvPunches + ",,TOTAL:,\(totalForEmp)\n" + ",,,\n"
                    }
                    
                    var standardHours : Double!
                    var overtimeHours : Double!
                    var totalHours : Double!
                    
                    if totalForEmp > 40 {
                        standardHours = 40
                        overtimeHours = Double(round(1000*(totalForEmp - 40))/1000)
                        totalHours = totalForEmp
                    } else {
                        standardHours = totalForEmp - vacationHours
                        totalHours = totalForEmp
                        overtimeHours = 0
                    }
                    
                    
                    if (!self.detail) {
                        self.csvPunches = self.csvPunches + "\(employeeName!),\(standardHours),\(overtimeHours),\(vacationHours),\(totalForEmp)\n"
                    }
                    
                    
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
        let docs = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0] 
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
        self.loadingUI.stopAnimation()
    }
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
        return viewController
    }
    
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
 }
