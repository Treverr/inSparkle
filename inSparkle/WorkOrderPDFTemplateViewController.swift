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
        
        dateCreatedLabel.text = DateFormatter.localizedString(from: workOrderObject.createdAt!, dateStyle: .short, timeStyle: .none)
        
        schedTimeLabel.text = ""
        customerAddressCityLabel.text = ""
        
        laborTableView.delegate = self
        laborTableView.separatorInset = UIEdgeInsets.zero
        partsTableView.delegate = self
        partsTableView.separatorInset = UIEdgeInsets.zero
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
        
        self.generatePDF()
        
    }
    
    func generatePDF() {
        let pdfData = NSMutableData()
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        UIGraphicsBeginPDFContextToData(pdfData, bounds, nil)
        
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        pdfContext.interpolationQuality = .high
        pdfView.drawHierarchy(in: self.pdfView.bounds, afterScreenUpdates: true)
        
        
        UIGraphicsEndPDFContext()
        
        let tmp = NSTemporaryDirectory() + "WorkOrder.pdf"
        pdfData.write(toFile: tmp, atomically: true)
        
        let info : UIPrintInfo = UIPrintInfo(dictionary: nil)
        info.orientation = UIPrintInfoOrientation.portrait
        info.outputType = UIPrintInfoOutputType.grayscale
        info.jobName = "Work Order"
        
        GlobalFunctions().printToPrinter(pdfData, printInfo: info, view: self)
    }
}

    extension WorkOrderPDFTemplateViewController : UITableViewDelegate, UITableViewDataSource {
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var returnCell : UITableViewCell!
            
            if tableView == partsTableView {
                if workOrderObject.parts != nil {
                    
                    var keyList : [String] {
                        get {
                            return Array(partCounts.keys)
                        }
                    }
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "partCell") as! PDFPartTableViewCell
                    
                    let partTitle = keyList[(indexPath as NSIndexPath).row]
                    
                    cell.qty.text = String(partCounts[partTitle]!)
                    cell.part.text = partTitle
                    cell.layoutMargins = UIEdgeInsets.zero
                    
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
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "laborCell") as! PDFLaborTableViewCell
                    
                    let partTitle = keyList[(indexPath as NSIndexPath).row]
                    
                    cell.qty.text = String(laborCounts[partTitle]!)
                    cell.part.text = partTitle
                    cell.layoutMargins = UIEdgeInsets.zero
                    
                    returnCell = cell
                }
            }
            
            return returnCell
        }
    }
    
    
    extension WorkOrderPDFTemplateViewController : UIDocumentInteractionControllerDelegate {
        
        func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
            return self.view.frame
        }
        
        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            timeToDismiss = true
            self.dismiss(animated: true, completion: nil)
        }
        
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            let viewController: UIViewController = UIViewController()
            self.present(viewController, animated: true, completion: nil)
            return viewController
        }
        
    }
    
    extension UIImage {
        convenience init(view: UIView) {
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.init(cgImage: image!.cgImage!)
        }
    }
    
    extension UIView {
        func toImage() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
}
