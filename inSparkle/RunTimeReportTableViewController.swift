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
        
        NotificationCenter.default.addObserver(self, selector: #selector(RunTimeReportTableViewController.updateStartDateLabel), name: NSNotification.Name(rawValue: "updateStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RunTimeReportTableViewController.updateEndDateLabel), name: NSNotification.Name(rawValue: "updateEnd"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateStart"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateEnd"), object: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // First Section
        if (indexPath as NSIndexPath).section == 0 {
            // First Cell
            if (indexPath as NSIndexPath).row == 0 {
                
                displayPopover("CalendarDatePicker", indexPath: indexPath)
                
                TimeClockReportAllEmployee.startEnd = "start"
            }
            
            if (indexPath as NSIndexPath).row == 1 {
                
                displayPopover("CalendarDatePicker", indexPath: indexPath)
                
                TimeClockReportAllEmployee.startEnd = "end"
                
            }
        }
    }
    
    func displayPopover(_ vcID : String, indexPath : IndexPath) {
        let storyboard = UIStoryboard(name: "TimeClockReport", bundle: nil)
        let x = self.view.center
        self.tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard.instantiateViewController(withIdentifier: vcID)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: (x.x - 25), y: x.y, width: 0, height: 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.present(vc, animated: true, completion: nil)
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
        loadingBackground.backgroundColor = UIColor.black
        
    }
    
    @IBAction func runReportButton(_ sender: AnyObject) {
        
        performSelector(onMainThread: #selector(RunTimeReportTableViewController.swiftActive), with: nil, waitUntilDone: true)

        let startDateString = startDateLabel.text
        let endDateString = endDateLabel.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
        
        let startDate : Date = formatter.date(from: startDateString!)!
        var endDate : Date = formatter.date(from: endDateString!)!
        
        let cal : Calendar = Calendar.current
        endDate = (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: endDate, options: NSCalendar.Options(rawValue: 0))!
        print(endDate)
        
        getEmployees(startDate, endDate: endDate)
        
    }
    
    var employeeArray = [Employee]()
    
    func getEmployees(_ startDate : Date, endDate : Date) {
        let query = Employee.query()
        query?.findObjectsInBackground(block: { (employees:[PFObject]?, error:Error?) -> Void in
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
    var error: ErrorPointer = nil
    
    func getTimeCardForEachEmployee(_ employee : Employee, startDate : Date, endDate : Date) {
        if !detail {
            csvPunches = "Employee,StandardHours,OvertimeHours,VacationHours,TotalTime\n"
            csvPunches += "Marti Ennis,Salary,-,-,-\n"
            csvPunches += "Tom Sedletzeck,Salary,-,-,-\n"
            csvPunches += "Robert Casad,Salary,-,-,-\n"
        }
        var employeeName : String?
        var complete : Bool = false
        let timeCardQuery = TimePunchCalcObject.query()
        timeCardQuery?.whereKey("employee", equalTo: employee)
        timeCardQuery?.whereKey("timePunchedIn", greaterThan: startDate)
        timeCardQuery?.whereKey("timePunchedOut", lessThan: endDate)
        expectedPunches = expectedPunches + (timeCardQuery?.countObjects(error))!
        print(expectedPunches)
        timeCardQuery?.findObjectsInBackground(block: { (punches : [PFObject]?, error : Error?) -> Void in
            if error == nil {
                
                var totalForEmp : Double! = 0
                var vacationHours : Double = 0.0
                
                for punch in punches! {
                    let thePunch = punch as! TimePunchCalcObject
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    formatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
                    
                    employeeName = "\(employee.firstName) \(employee.lastName)"
                    var timePunchedIn = formatter.string(from: thePunch.timePunchedIn)
                    timePunchedIn = timePunchedIn.replacingOccurrences(of: ",", with: " ")
                    var timePunchedOut = formatter.string(from: thePunch.timePunchedOut)
                    timePunchedOut = timePunchedOut.replacingOccurrences(of: ",", with: " ")
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
                        self.csvPunches = self.csvPunches + "\(employeeName!),\(standardHours!),\(overtimeHours!),\(vacationHours),\(totalForEmp!)\n"
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
        
        let data = textToShare.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        saveCSV(textToShare)
        
    }
    
    func sheet(_ whatToShare : AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [whatToShare], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    var docController: UIDocumentInteractionController?
    
    func saveCSV(_ whatToSave : NSMutableString) {
        let x = self.view.center
        let docs = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0] 
        let writePath = docs + "TimeCardReport.csv"
        do {
            try whatToSave.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
            print("Wrote File")
            print(writePath)
        } catch {
            
        }
        docController = UIDocumentInteractionController(url: URL(fileURLWithPath: writePath))
        docController!.delegate = self
        docController!.presentPreview(animated: true)
        self.loadingUI.stopAnimating()
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
        return viewController
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
 }
