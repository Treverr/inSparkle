//
//  PoolOpeningPDFViewController.swift
//
//
//  Created by Trever on 2/3/16.
//
//

import UIKit
import UIView_HierarchicalDrawing
import Parse

class PoolOpeningPDFViewController: UIViewController {
    
    @IBOutlet var theView : UIView!
    @IBOutlet var customerName : UILabel!
    @IBOutlet var address : UILabel!
    @IBOutlet var phoneNumber : UILabel!
    @IBOutlet var openingWeek : UILabel!
    @IBOutlet var openingDate : UILabel!
    @IBOutlet var confirmedWith : UILabel!
    @IBOutlet var typeOfWinterCover : UILabel!
    @IBOutlet var itemLocation : UILabel!
    @IBOutlet var bringChemicals : UILabel!
    @IBOutlet var takeTrash : UILabel!
    @IBOutlet var notes : UILabel!
    @IBOutlet var accountNumber : UILabel!
    @IBOutlet var accountNumberBarcode : UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weekTitle: UILabel!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var requirement1: UILabel!
    @IBOutlet weak var requirement2: UILabel!
    @IBOutlet weak var requirement3: UILabel!
    
    var pageCount : Int = 0
    var pagesLeft : Int = 0
    var data = [ScheduleObject]()
    var firsRun : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notes.numberOfLines = 0
        
        self.data = POCReportData.POCData
        
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.createPdfFromView(self.theView, saveToDocumentsWithFileName: "POC")
        }
   
    }
    
    func createPdfFromView(_ aView: UIView, saveToDocumentsWithFileName fileName: String) {
        
        if firsRun {
            pagesLeft = data.count
            firsRun = false
        }
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        while pagesLeft > 0 {
            
            print(pagesLeft)
            
            if pagesLeft != 0 {
                let num = data[pagesLeft - 1]
                
                print(num)
                
                print(customerName)
                
                customerName.text = num.customerName
                address.text = num.customerAddress
                phoneNumber.text = num.customerPhone
                openingWeek.text! = GlobalFunctions().stringFromDateShortStyle(num.weekStart) + " - " + GlobalFunctions().stringFromDateShortStyleNoTimezone(num.weekEnd)
                if num.confirmedDate != nil {
                    openingDate.text = GlobalFunctions().stringFromDateShortStyle(num.confirmedDate!)
                } else {
                    openingDate.text = "NOT CONFIRMED"
                }
                if num.confirmedWith != nil {
                    confirmedWith.text = num.confirmedWith!
                } else {
                    confirmedWith.text = "NOT CONFIRMED"
                }
                typeOfWinterCover.text = num.coverType
                itemLocation.text = num.locEssentials
                if (num.bringChem) {
                    bringChemicals.text = "Yes"
                } else {
                    bringChemicals.text = "No"
                }
                if (num.takeTrash) {
                    takeTrash.text = "Yes"
                } else {
                    takeTrash.text = "No"
                }
                
                if num.type == "Closing" {
                    
                    titleLabel.text = "Pool Closing"
                    weekTitle.text = "Closing Week:"
                    dateTitle.text = "Closing Date:"
                    
                    requirement1.text = "• Water level lowered to 1-inch below skimmer (do not lower water for electric covers)"
                    requirement2.text = "• Plugs, winter cover, and winter accessories by pool for service crews"
                    requirement3.text = "• Pool cleaned out to customer's satisfaction"
                    
                }
                notes.text = num.notes!
                accountNumber.text! = num.accountNumber!
                if !accountNumber.text!.isEmpty {
                    accountNumberBarcode.image = Barcode.fromString(num.accountNumber!)!
                }
                
                UIGraphicsBeginPDFPage()
                
                guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
                
                pdfContext.interpolationQuality = .high
                aView.drawHierarchy()
                
                pagesLeft = pagesLeft - 1
                
            }
            
            if pagesLeft == 0 {
                
                UIGraphicsEndPDFContext()
                
                let info : UIPrintInfo = UIPrintInfo(dictionary: nil)
                info.orientation = UIPrintInfoOrientation.portrait
                info.outputType = UIPrintInfoOutputType.grayscale
                info.jobName = customerName.text! + " PoC"
                
                GlobalFunctions().printToPrinter(pdfData, printInfo: info, view: self)
                
//                if let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
//                    let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
//                    debugPrint(documentsFileName)
//                    pdfData.writeToFile(documentsFileName, atomically: true)
//                    
//                    let docURL = NSURL.fileURLWithPath(documentsFileName)
//                    var docController : UIDocumentInteractionController!
//                    docController = UIDocumentInteractionController(URL: docURL)
//                    docController.delegate = self
//                    docController.presentPreviewAnimated(true)
//                }
            }
        }
    }
    
}

extension PoolOpeningPDFViewController : UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
        return viewController
    }
    
}
