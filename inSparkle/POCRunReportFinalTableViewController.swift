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
        
        var nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "updateStartLabel", name: "NotifyPOCUpdateStartLabel", object: nil)
        nc.addObserver(self, selector: "updateEndLabel", name: "NotifyPOCUpdateEndLabel", object: nil)
        
        repeat {
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
            
        } while POCReportFilters.filter.count > 3

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
        let vc = storyboard.instantiateViewControllerWithIdentifier("CalendarDatePicker")
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
        
        let overlay : UIView = UIView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.view.addSubview(overlay)
        
        let activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityMonitor.alpha = 1.0
        activityMonitor.center = self.view.center
        activityMonitor.hidesWhenStopped = true
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
        query?.whereKey("weekStart", greaterThan: startDate)
        query?.whereKey("weekEnd", lessThan: endDate)
        expectedReturn = expectedReturn + (query?.countObjects(error))!
        query?.findObjectsInBackgroundWithBlock({ (appts : [PFObject]?, error : NSError?) -> Void in
            if error == nil {
                for appt in appts! {
                    let object = appt as! ScheduleObject
                    let accountNumber = "TODO"
                    let custName = object.customerName
                    let custAddress = object.customerAddress
                    let custPhone = object.customerPhone
                    let weekSch = GlobalFunctions().stringFromDateShortStyle(object.weekStart) + GlobalFunctions().stringFromDateShortStyle(object.weekEnd)
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
                    let trash = object.takeTrash
                    let notes = object.notes
                    var confirmedBy : String?
                    if object.confrimedBy != nil {
                        confirmedBy = object.confrimedBy!
                    } else {
                        confirmedBy = ""
                    }
                    
                    self.csvPOC = self.csvPOC + "\(accountNumber),\(custName),\(weekSch),\(custAddress),\(custPhone),\(dateConfirmed),\(confirmedWith),\(typeOfWC),\(itemLoc),\(chem),\(trash),\(notes),\(confirmedBy)"
                    self.returnedPOC = self.returnedPOC + 1
                }
                
                if self.expectedReturn == 0 {
                    // TODO: Alert
                }
                
                if self.expectedReturn - self.returnedPOC == 0 {
                    self.shareTime()
                }
                
            }
        })
        
    }
    
    func shareTime() {
        let textToShare = NSMutableString()
        textToShare.appendFormat("%@\r", self.csvPOC)
        
        let data = textToShare.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:  false)
    }
    
    var docController : UIDocumentInteractionController?
    
    func saveCSV(save : NSMutableString) {
        let docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let pathDate = docs.stringByAppendingString("\(NSDate())")
        let writePath = pathDate.stringByAppendingString("-POCReport.csv")
        
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }
    

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func updateStartLabel() {
        
    }
    
    func updateEndLabel() {
        
    }
    
}
