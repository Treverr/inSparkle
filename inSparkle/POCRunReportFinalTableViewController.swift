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

        NotificationCenter.default.addObserver(self, selector: #selector(POCRunReportFinalTableViewController.updateStartDateLabel), name: NSNotification.Name(rawValue: "NotifyPOCUpdateStartLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(POCRunReportFinalTableViewController.updateEndDateLabel), name: NSNotification.Name(rawValue: "NotifyPOCUpdateEndLabel"), object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                displayPopoverCalendar((indexPath as NSIndexPath).row, indexPath: indexPath)
                POCRunReport.selectedCell = "startDate"
            }
            if (indexPath as NSIndexPath).row == 1 {
                displayPopoverCalendar((indexPath as NSIndexPath).row, indexPath: indexPath)
                POCRunReport.selectedCell = "endDate"
            }
        }
    }
    
    func displayPopoverCalendar(_ startOrEnd : Int, indexPath : IndexPath) {
        let storyboard = UIStoryboard(name: "POCReport", bundle: nil)
        let x = self.view.center
        self.tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalPicker")
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover : UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: (x.x - 25), y: x.y, width: 0, height: 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection()
        popover.popoverLayoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func runReport(_ sender: AnyObject) {
        
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
        
        let overlay : UIView = UIView(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        overlay.tag = 6969
        self.view.addSubview(overlay)
        
        let activityMonitor = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityMonitor.alpha = 1.0
        activityMonitor.center = self.view.center
        activityMonitor.hidesWhenStopped = true
        activityMonitor.tag = 6868
        self.view.addSubview(activityMonitor)
        activityMonitor.startAnimating()
        
        let startDateAsString = startDateLabel.text!
        let endDateASString = endDateLabel.text!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.timeZone = SparkleTimeZone.timeZone
        
        let startDate : Date = formatter.date(from: startDateAsString)!
        var endDate : Date = formatter.date(from: endDateASString)!

        let cal : Calendar = Calendar.current
        endDate = (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: endDate, options: NSCalendar.Options(rawValue: 0))!
        
        getSchedule(startDate, endDate: endDate, isActive: isActiveFilter, customers: customerFilter)
        
    }
    
    var returnedPOC = 0
    var expectedReturn = 0
    var error: ErrorPointer = nil
    var csvPOC = "Account Number, Customer Name, Week Scheduled, Address, Phone Number, Date Confirmed, Confirmed With, Type of Winter Cover, Item Location, Chemicals, Trash, Notes, Confirmed By"
    
    func getSchedule(_ startDate: Date, endDate: Date, isActive : Bool?, customers : CustomerData?) {

        let query = ScheduleObject.query()
        query?.whereKey("weekStart", greaterThanOrEqualTo: startDate)
        print(startDate)
        query?.whereKey("weekEnd", lessThanOrEqualTo: endDate)
        print(endDate)
        expectedReturn = expectedReturn + (query?.countObjects(error))!
        query?.findObjectsInBackground(block: { (appts : [PFObject]?, error : Error?) -> Void in
            if error == nil {
                for appt in appts! {
                    let object = appt as! ScheduleObject
                    let accountNumber = object.accountNumber!
                    let custName = object.customerName
                    let custAddress = object.customerAddress.replacingOccurrences(of: ",", with: " ").capitalized
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
                        notes = object.notes?.replacingOccurrences(of: "\n", with: " ")
                        notes = notes?.replacingOccurrences(of: ",", with: "")
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
                let vc = sb.instantiateViewController(withIdentifier: "PoolOpeningTemplate")
                POCReportData.POCData = appts as! [ScheduleObject]
                self.present(vc, animated: true, completion: {
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
        
        let data = textToShare.data(using: String.Encoding.utf8.rawValue, allowLossyConversion:  false)
        saveCSV(textToShare)
    }
    
    var docController : UIDocumentInteractionController?
    
    func saveCSV(_ save : NSMutableString) {
        let docs = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0]
        let writePath = docs + "POCReport.csv"
        
        do {
            try save.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
            print("Wrote File")
            print(writePath)
        } catch { }
        
        docController = UIDocumentInteractionController(url: URL(fileURLWithPath: writePath))
        docController!.delegate = self
        docController?.presentPreview(animated: true)
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
        return viewController
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    let global = GlobalFunctions()
    
    func updateStartDateLabel() {
        
        startDateLabel.text =  POCRunReport.selectedDate

    }
    
    func updateEndDateLabel() {
        
        endDateLabel.text =  POCRunReport.selectedDate
        
    }
    
}
