//
//  POCRunReportFinalTableViewController.swift
//  
//
//  Created by Trever on 12/15/15.
//
//

import UIKit
import Parse

class POCRunReportFinalTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    var theFilter : [String]!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var isActiveFilter  : Bool?
    var customerFilter  : CustomerData?
    var openCloseFilter : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(POCRunReportFinalTableViewController.updateStartDateLabel), name: "NotifyPOCUpdateStartLabel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(POCRunReportFinalTableViewController.updateEndDateLabel), name: "NotifyPOCUpdateEndLabel", object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                displayPopoverCalendar(indexPath.row, indexPath: indexPath)
                POCRunReport.selectedCell = "startDate"
            }
            if indexPath.row == 1 {
                displayPopoverCalendar(indexPath.row, indexPath: indexPath)
                POCRunReport.selectedCell = "endDate"
            }
        }
    }
    
    func displayPopoverCalendar(startOrEnd : Int, indexPath : NSIndexPath) {
        let storyboard = UIStoryboard(name: "POCReport", bundle: nil)
        let x = self.view.center
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CalPicker")
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRectMake((x.x - 25), x.y, 0, 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func runReport(sender: AnyObject) {
        
        theFilter = POCReportFilters.filter
        
        if theFilter[0] != "allCustomers" {
            // Filtering by customer
        }
        
        if theFilter[1] == "Opening" {
            openCloseFilter = "Opening"
        }
        
        if theFilter[1] == "Closing" {
            openCloseFilter = "Opening"
        }
        
        if theFilter[2] == "active" {
            isActiveFilter = true
        }
        
        if theFilter[2] == "inactive" {
            isActiveFilter = false
        }
        
        let overlay : UIView = UIView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        overlay.tag = 6969
        self.view.addSubview(overlay)
        
        let activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityMonitor.alpha = 1.0
        activityMonitor.center = self.view.center
        activityMonitor.hidesWhenStopped = true
        activityMonitor.tag = 6868
        self.view.addSubview(activityMonitor)
        activityMonitor.startAnimating()
        
        let startDateAsString = startDateLabel.text!
        let endDateASString = endDateLabel.text!
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let startDate : NSDate = formatter.dateFromString(startDateAsString)!
        var endDate : NSDate = formatter.dateFromString(endDateASString)!

        let cal : NSCalendar = NSCalendar.currentCalendar()
        endDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: endDate, options: NSCalendarOptions(rawValue: 0))!
        
        getSchedule(startDate, endDate: endDate, isActive: isActiveFilter, customers: customerFilter)
        
    }
    
    var returnedPOC = 0
    var expectedReturn = 0
    var error = NSErrorPointer()
    var csvPOC = "Account Number, Customer Name, Week Scheduled, Address, Phone Number, Date Confirmed, Confirmed With, Type of Winter Cover, Item Location, Chemicals, Trash, Notes, Confirmed By"
    
    func getSchedule(startDate: NSDate, endDate: NSDate, isActive : Bool?, customers : CustomerData?) {

        let query = ScheduleObject.query()
        query?.whereKey("weekStart", greaterThanOrEqualTo: startDate)
        print(startDate)
        query?.whereKey("weekEnd", lessThanOrEqualTo: endDate)
        print(endDate)
        expectedReturn = expectedReturn + (query?.countObjects(error))!
        query?.findObjectsInBackgroundWithBlock({ (appts : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                for appt in appts! {
                    let object = appt as! ScheduleObject
                    let accountNumber = object.accountNumber!
                    let custName = object.customerName
                    let custAddress = object.customerAddress.stringByReplacingOccurrencesOfString(",", withString: " ").capitalizedString
                    print(object.customerAddress)
                    let custPhone = object.customerPhone
                    let weekSch = GlobalFunctions().stringFromDateShortStyle(object.weekStart) + " - " + GlobalFunctions().stringFromDateShortStyle(object.weekEnd)
                    var dateConfirmed : String?
                    if object.confirmedDate != nil {
                        dateConfirmed = GlobalFunctions().stringFromDateShortStyle(object.confirmedDate!)
                    } else {
                        dateConfirmed = ""
                    }
                    let confirmedWith = ""
                    let typeOfWC = object.coverType
                    let itemLoc = object.locEssentials
                    let chem = object.bringChem
                    var takeChem : String!
                    if (chem) {
                        takeChem = "Yes"
                    } else {
                        takeChem = "No"
                    }
                    let trash = object.takeTrash
                    var takeTrash : String!
                    if (trash) {
                        takeTrash = "Yes"
                    } else {
                        takeTrash = "No"
                    }
                    var notes : String?
                    if object.notes == nil {
                        notes = ""
                    } else {
                        notes = object.notes?.stringByReplacingOccurrencesOfString("\n", withString: " ")
                        notes = notes?.stringByReplacingOccurrencesOfString(",", withString: "")
                        print(notes)
                    }
                    
                    var confirmedBy : String?
                    if object.confrimedBy != nil {
                        confirmedBy = object.confrimedBy!
                    } else {
                        confirmedBy = ""
                    }
                    
                    self.csvPOC = self.csvPOC + "\n\(accountNumber),\(custName),\(weekSch),\(custAddress),\(custPhone),\(dateConfirmed!),\(confirmedWith),\(typeOfWC),\(itemLoc),\(takeChem),\(takeTrash),\(notes!),\(confirmedBy!)"
                    self.returnedPOC = self.returnedPOC + 1
                }
                
                if self.expectedReturn == 0 {
                    // TODO: Alert
                }
                
            }
            
            if error == nil {
                let sb = UIStoryboard(name: "OpeningPDFTemplate", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("PoolOpeningTemplate")
                POCReportData.POCData = appts as! [ScheduleObject]
                self.presentViewController(vc, animated: true, completion: {
                    if let overlayView = self.view.viewWithTag(6969) {
                        overlayView.removeFromSuperview()
                    }
                    if let activityIndicator = self.view.viewWithTag(6868) {
                        activityIndicator.removeFromSuperview()
                    }
                })
            }
            
        })
        
    }
    
    func shareTime() {
        let textToShare = NSMutableString()
        textToShare.appendFormat("%@\r", self.csvPOC)
        
        let data = textToShare.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:  false)
        saveCSV(textToShare)
    }
    
    var docController : UIDocumentInteractionController?
    
    func saveCSV(save : NSMutableString) {
        let docs = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0]
        let writePath = docs.stringByAppendingString("POCReport.csv")
        
        do {
            try save.writeToFile(writePath, atomically: true, encoding: NSUTF8StringEncoding)
            print("Wrote File")
            print(writePath)
        } catch { }
        
        docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: writePath))
        docController!.delegate = self
        docController?.presentPreviewAnimated(true)
    }
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
        return viewController
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }
    

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    let global = GlobalFunctions()
    
    func updateStartDateLabel() {
        
        startDateLabel.text =  POCRunReport.selectedDate

    }
    
    func updateEndDateLabel() {
        
        endDateLabel.text =  POCRunReport.selectedDate
        
    }
    
}
