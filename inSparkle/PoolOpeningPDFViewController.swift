//
//  PoolOpeningPDFViewController.swift
//  
//
//  Created by Trever on 2/3/16.
//
//

import UIKit
import UIView_HierarchicalDrawing

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
    
    var pageCount : Int = 0
    var pagesLeft : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        generatePDF()
        
    }
    
    @IBAction func generatePDF() {
        repeat {
        createPdfFromView(theView, saveToDocumentsWithFileName: "POC")
        } while pagesLeft > 0
    }
    
    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String) {
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        CGContextSetInterpolationQuality(pdfContext, .High)
        aView.drawHierarchy()
        UIGraphicsEndPDFContext()
        
        if pagesLeft == 0 {
            if let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
                let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
                debugPrint(documentsFileName)
                pdfData.writeToFile(documentsFileName, atomically: true)
            }
        }
    }

}
