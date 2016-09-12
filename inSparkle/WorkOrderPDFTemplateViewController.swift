//
//  WorkOrderPDFTemplateViewController.swift
//  inSparkle
//
//  Created by Trever on 2/16/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import UIView_HierarchicalDrawing

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
        pdfView.drawHierarchy()
        
        UIGraphicsEndPDFContext()
        
        if let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let documentFileName = docDir + "/" + "WorkOrder.pdf"
            print(documentFileName)
            pdfData.writeToFile(documentFileName, atomically: true)
            
            if self.isViewLoaded() {
                let docURL = NSURL.fileURLWithPath(documentFileName)
                print(docURL)
                var docController : UIDocumentInteractionController!
                docController = UIDocumentInteractionController(URL: docURL)
                docController.delegate = self
                docController.presentPreviewAnimated(true)
            } else {
                while self.isViewLoaded() == false {
                    if self.isViewLoaded() {
                        let docURL = NSURL.fileURLWithPath(documentFileName)
                        print(docURL)
                        var docController : UIDocumentInteractionController!
                        docController = UIDocumentInteractionController(URL: docURL)
                        docController.delegate = self
                        docController.presentPreviewAnimated(true)
                    } else {
                        print("Not")
                    }
                }
            }
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































