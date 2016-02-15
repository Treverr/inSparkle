//
//  ChemCheckoutPDFReportTemplateViewController.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import UIView_HierarchicalDrawing

class ChemCheckoutPDFReportTemplateViewController: UIViewController {
    
    @IBOutlet var reportDateLabel: UILabel!
    @IBOutlet var forDateLabel: UILabel!
    var counts : [String : Int] = [:]
    
    var onEmployee : Int = 0
    var theEmployees : [Employee]?
    var numberOfEmployees : Int = 0
    
    @IBOutlet var pdfView: UIView!
    
    @IBOutlet var chemicalCheckoutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(theEmployees)
        
        // Set the report date
        let reportDateFormatter = NSDateFormatter()
        reportDateFormatter.dateStyle = .ShortStyle
        reportDateFormatter.timeStyle = .ShortStyle
        let reportDateString = reportDateFormatter.stringFromDate(NSDate())
        reportDateLabel.text = reportDateString
        
        let forDateFormatter = NSDateFormatter()
        forDateFormatter.dateStyle = .ShortStyle
        forDateFormatter.timeStyle = .NoStyle
        forDateLabel.text = forDateFormatter.stringFromDate(NSDate())
        
        chemicalCheckoutTableView.delegate = self
        chemicalCheckoutTableView.dataSource = self
        
        numberOfEmployees = theEmployees!.count
        
        getData()
    }
    
    var chemicals = NSMutableArray()
    
    func getData() {
    
        var theEmployee = theEmployees![onEmployee]
        let query = CheckoutModel.query()
        let todayStart = NSDate().startOfDay
        let todayEnd = NSDate().endOfDay!
        
        query!.whereKey("employee", equalTo: theEmployee)
        query?.whereKey("timeCheckedOut", greaterThan: todayStart)
        query?.whereKey("timeCheckedOut", lessThan: todayEnd)
        query?.findObjectsInBackgroundWithBlock({ (results : [PFObject]?, error : NSError?) in
            if error == nil {
                if results?.count != 0 {
                    for result in results! {
                        let theRes = result.objectForKey("chemicalsCheckedOut") as! Array<String>
                        //                    let theChems = theRes.chemicalsCheckedOut as! NSArray
                        self.chemicals.addObjectsFromArray(theRes as [String])
                        print(self.chemicals)
                    }
                    for item in self.chemicals {
                        self.counts[item as! String] = (self.counts[item as! String] ?? 0) + 1
                    }
                } else {
                    self.chemicals.addObject("NONE")
                    for item in self.chemicals {
                        self.counts[item as! String] = (self.counts[item as! String] ?? 0) + 1
                    }
                }
                self.chemicalCheckoutTableView.reloadData()
            }
        })
    }
    
    var pdfData = NSMutableData()
    var firstRun = true
    
    func createPDF() {
        
        if firstRun {
            print(pdfData.length)
            let bounds = CGRectMake(0, 0, 792, 612)
            UIGraphicsBeginPDFContextToData(pdfData, bounds, nil)
            firstRun = false
        }
        
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        CGContextSetInterpolationQuality(pdfContext, .High)
        pdfView.drawHierarchy()
        
        if numberOfEmployees == onEmployee + 1 {
            UIGraphicsEndPDFContext()
            if let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
                let documentFileName = docDir + "/" + "Chemicals.pdf"
                print(documentFileName)
                pdfData.writeToFile(documentFileName, atomically: true)
                
                if self.isViewLoaded() {
                        let docURL = NSURL.fileURLWithPath(documentFileName)
                        var docController : UIDocumentInteractionController!
                        docController = UIDocumentInteractionController(URL: docURL)
                        docController.delegate = self
                        docController.presentPreviewAnimated(true)
                } else  {
                    while self.isViewLoaded() == false {
                        if self.isViewLoaded() {
                            let docURL = NSURL.fileURLWithPath(documentFileName)
                            var docController : UIDocumentInteractionController!
                            docController = UIDocumentInteractionController(URL: docURL)
                            docController.delegate = self
                            docController.presentPreviewAnimated(true)
                        }
                    }
                }
            }
            
        } else {
            self.chemicals.removeAllObjects()
            self.counts.removeAll()
            onEmployee = onEmployee + 1
            getData()
        }
    }
}

extension ChemCheckoutPDFReportTemplateViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = chemicalCheckoutTableView.dequeueReusableCellWithIdentifier("chemCell") as! ChemicalCheckoutPDFTemplateTableViewCell
        let itemName = chemicals[indexPath.row] as! String
        let theEmp = theEmployees![onEmployee]
        
        cell.chemicalName.text = itemName
        cell.qtyLabel.text = String(counts[itemName]!)
        cell.employeeName.text = theEmp.firstName.capitalizedString + " " + theEmp.lastName.capitalizedString
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
            createPDF()
        }
    }
    
}

extension ChemCheckoutPDFReportTemplateViewController : UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
        return viewController
    }
    
}
