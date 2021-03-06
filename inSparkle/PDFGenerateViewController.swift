//
//  PDFGenerateViewController.swift
//  inSparkle
//
//  Created by Trever on 2/3/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import QuartzCore

class PDFGenerateViewController: UIViewController {
    
    @IBOutlet var theView: UIView!
    
    @IBAction func generateButton(_ sender: AnyObject) {
        createPdfFromView(theView, saveToDocumentsWithFileName: "Test")
    }
    
    func createPdfFromView(_ aView: UIView, saveToDocumentsWithFileName fileName: String) {
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
