//
//  WorkOrderPDFTemplateViewController.swift
//  inSparkle
//
//  Created by Trever on 2/16/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class WorkOrderPDFTemplateViewController: UIViewController {
    
    var workOrderObject : WorkOrders!
    
    var timeToDismiss : Bool = false
    
    @IBOutlet var pdfView: UIView!
    @IBOutlet var customerNameLabel: UILabel!
    @IBOutlet var customerAddressLabel: UILabel!
    @IBOutlet var customerAddressCityLabel: UILabel!
    @IBOutlet var customerPhoneLabel: UILabel!
    @IBOutlet var customerAltPhoneLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var schedTimeLabel: UILabel!
    @IBOutlet var techLabel: UILabel!
    @IBOutlet var wtbpTextView: UITextView!
    @IBOutlet var dowTextView: UITextView!
    @IBOutlet var recTextView: UITextView!
    @IBOutlet var tripOneDateLabel: UILabel!
    @IBOutlet var tripOneTimeArriveLabel: UILabel!
    @IBOutlet var tripOneTimeDepartLabel: UILabel!
    @IBOutlet var tripTwoDateLabel: UILabel!
    @IBOutlet var tripTwoTimeArriveLabel: UILabel!
    @IBOutlet var tripTwoDepartLabel: UILabel!
    @IBOutlet var unitMakeLabel: UILabel!
    @IBOutlet var unitModelLabel: UILabel!
    @IBOutlet var unitSerialLabel: UILabel!
    @IBOutlet var partsTableView: UITableView!
    @IBOutlet var laborTableView: UITableView!
    @IBOutlet var dateCreatedLabel: UILabel!
    
    var partCounts : [String : Int] = [:]
    var laborCounts : [String : Int] = [:]
    
    override func viewDidLoad() {
        if workOrderObject.parts != nil {
            for item in workOrderObject.parts! {
                partCounts[item as! String] = (partCounts[item as! String] ?? 0) + 1
            }
        }
        
        if workOrderObject.labor != nil {
            for item in workOrderObject.labor! {
                laborCounts[item as! String] = (laborCounts[item as! String] ?? 0) + 1
            }
        }
        
        dateCreatedLabel.text = NSDateFormatter.localizedStringFromDate(workOrderObject.createdAt!, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        
        schedTimeLabel.text = ""
        customerAddressCityLabel.text = ""
        
        laborTableView.delegate = self
        laborTableView.separatorInset = UIEdgeInsetsZero
        partsTableView.delegate = self
        partsTableView.separatorInset = UIEdgeInsetsZero
        laborTableView.dataSource = self
        partsTableView.dataSource = self
        partsTableView.reloadData()
        laborTableView.reloadData()
        
        let gf = GlobalFunctions()
        if workOrderObject != nil {
            customerNameLabel.text = workOrderObject.customerName
            customerAddressLabel.text = workOrderObject.customerAddress
            customerPhoneLabel.text = workOrderObject.customerPhone
            if workOrderObject.customerAltPhone != nil {
                customerAltPhoneLabel.text = workOrderObject.customerAltPhone
            } else {
                customerAltPhoneLabel.text = ""
            }
            if workOrderObject.date != nil {
                dateLabel.text = gf.stringFromDateShortStyle(workOrderObject.date)
            } else {
                dateLabel.text = ""
            }
            if workOrderObject.technician != nil {
                techLabel.text = workOrderObject.technician
            } else {
                techLabel.text = ""
            }
            if workOrderObject.technicianPointer != nil {
                techLabel.text = workOrderObject.technicianPointer!.firstName + " " + workOrderObject.technicianPointer!.lastName
            }
            if workOrderObject.workToBePerformed != nil {
                wtbpTextView.text = workOrderObject.workToBePerformed
            } else  {
                wtbpTextView.text = ""
            }
            if workOrderObject.descOfWork != nil {
                dowTextView.text = workOrderObject.descOfWork
            } else {
                dowTextView.text = ""
            }
            
            recTextView.text = ""
            
            tripOneDateLabel.text = ""
            tripOneTimeArriveLabel.text = ""
            
            tripOneTimeDepartLabel.text = ""
            
            tripTwoDateLabel.text = ""
            tripTwoTimeArriveLabel.text = ""
            
            tripTwoDepartLabel.text = ""
            
            if workOrderObject.unitMake != nil {
                unitMakeLabel.text = workOrderObject.unitMake
            } else {
                unitMakeLabel.text = ""
            }
            if workOrderObject.unitModel != nil {
                unitModelLabel.text = workOrderObject.unitModel
            } else {
                unitModelLabel.text = ""
            }
            if workOrderObject.unitSerial != nil {
                unitSerialLabel.text = workOrderObject.unitSerial
            } else {
                unitSerialLabel.text = ""
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if timeToDismiss == false {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.generatePDF()
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func generatePDF() {
        let pdfData = NSMutableData()
        let bounds = CGRectMake(0, 0, 612, 792)
        
        UIGraphicsBeginPDFContextToData(pdfData, bounds, nil)
        
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        CGContextSetInterpolationQuality(pdfContext, .High)
        pdfView.drawViewHierarchyInRect(self.pdfView.bounds, afterScreenUpdates: true)
        
        
        UIGraphicsEndPDFContext()
        
        let tmp = NSTemporaryDirectory().stringByAppendingString("WorkOrder.pdf")
        pdfData.writeToFile(tmp, atomically: true)
        
        let info : UIPrintInfo = UIPrintInfo(dictionary: nil)
        info.orientation = UIPrintInfoOrientation.Portrait
        info.outputType = UIPrintInfoOutputType.Grayscale
        info.jobName = "Work Order"
        
        if NSUserDefaults.standardUserDefaults().URLForKey("printer") != nil {
            let printer = UIPrinter(URL: NSUserDefaults.standardUserDefaults().URLForKey("printer")!)
            printer.contactPrinter { (available) in
                if available {
                    
                    let printInteraction = UIPrintInteractionController.sharedPrintController()
                    
                    printInteraction.printingItem = pdfData
                    printInteraction.printInfo = info
                    
                    printInteraction.printToPrinter(printer, completionHandler: { (printerController, completed, error) in
                        if completed {
                            let alert = UIAlertController(title: "Printed!", message: nil, preferredStyle: .Alert)
                            self.presentViewController(alert, animated: true, completion: nil)
                            let delay = 1.0 * Double(NSEC_PER_SEC)
                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue(), {
                                alert.dismissViewControllerAnimated(true, completion: {
                                    self.dismissViewControllerAnimated(false, completion: nil)
                                })
                            })
                        }
                    })
                    
                }
            }
        } else {
            self.dismissViewControllerAnimated(false, completion: nil)
            let alert = UIAlertController(title: "Select Printer", message: "\nPlease select a printer in the More section and then try your print again", preferredStyle: .Alert)
            let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okayButton)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

    extension WorkOrderPDFTemplateViewController : UITableViewDelegate, UITableViewDataSource {
        
        
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var theReturn : Int!
            if tableView == partsTableView {
                theReturn = partCounts.count
            }
            
            if tableView == laborTableView {
                if workOrderObject.labor != nil {
                    theReturn = workOrderObject.labor!.count
                } else {
                    theReturn = 0
                }
            }
            
            return theReturn
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var returnCell : UITableViewCell!
            
            if tableView == partsTableView {
                if workOrderObject.parts != nil {
                    
                    var keyList : [String] {
                        get {
                            return Array(partCounts.keys)
                        }
                    }
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier("partCell") as! PDFPartTableViewCell
                    
                    let partTitle = keyList[indexPath.row]
                    
                    cell.qty.text = String(partCounts[partTitle]!)
                    cell.part.text = partTitle
                    cell.layoutMargins = UIEdgeInsetsZero
                    
                    returnCell = cell
                }
            }
            
            if tableView == laborTableView {
                if workOrderObject.parts != nil {
                    
                    var keyList : [String] {
                        get {
                            return Array(laborCounts.keys)
                        }
                    }
                    print(self.partCounts)
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier("laborCell") as! PDFLaborTableViewCell
                    
                    let partTitle = keyList[indexPath.row]
                    
                    cell.qty.text = String(laborCounts[partTitle]!)
                    cell.part.text = partTitle
                    cell.layoutMargins = UIEdgeInsetsZero
                    
                    returnCell = cell
                }
            }
            
            return returnCell
        }
    }
    
    
    extension WorkOrderPDFTemplateViewController : UIDocumentInteractionControllerDelegate {
        
        func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
            return self.view.frame
        }
        
        func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
            timeToDismiss = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
            let viewController: UIViewController = UIViewController()
            self.presentViewController(viewController, animated: true, completion: nil)
            return viewController
        }
        
    }
    
    extension UIImage {
        convenience init(view: UIView) {
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.init(CGImage: image!.CGImage!)
        }
    }
    
    extension UIView {
        func toImage() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
            
            drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
}
