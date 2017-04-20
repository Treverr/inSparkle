//
//  PayrollReportHTML.swift
//  inSparkle
//
//  Created by Trever on 4/19/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class PayrollReportHTML : NSObject {
    
    let pathToHTMLTemplate = Bundle.main.path(forResource: "report", ofType: "html")
    
    let pathToEmployeeLine = Bundle.main.path(forResource: "employeeline", ofType: "html")
    
    let logoImage = Bundle.main.path(forResource: "payrollreportlogo", ofType: "png")
    
    var pdfFileName : String!
    
    override init() {
        super.init()
    }
    
    func renderInvoice(periodDates : String, employees : [EmployeePayrollReportModel]) -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = SparkleTimeZone.timeZone
        
        let date = dateFormatter.string(from: Date())
        
        print(employees.count)
        
        do {
            var HTMLContent = try String(contentsOfFile: pathToHTMLTemplate!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO_IMAGE#", with: logoImage!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PAY_PERIOD_DATES#", with: periodDates)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#RUN_DATE#", with: date)
            
            var allLines = ""
            
            for emp in employees {
                
                var itemHTMLContent : String! = try String(contentsOfFile: pathToEmployeeLine!)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#EMPLOYEE#", with: emp.employeeName)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#STD_HOURS#", with: emp.standardHours)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#OT_HOURS#", with: emp.overtimeHours)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#TTL_HOURS#", with: emp.total)
                
                allLines += itemHTMLContent
                
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LINES#", with: allLines)
            
            return HTMLContent
        } catch {
            
        }
        
        return nil
        
    }
    
    func exportHTMLContentToPDF(HTMLContent : String, printFormatter : UIViewPrintFormatter) {
        let printPageRenderer = printPayrollToPDF()
        
        
//        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsiingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString
        
        pdfFileName = directory + fileName + ".pdf"
        
        pdfData.write(toFile: pdfFileName, atomically: true)
        
        thePayrollView.presentPDF(fileName: pdfFileName)
        
    }
    
    
    func drawPDFUsiingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        
        UIGraphicsEndPDFContext()
        
        return data
    }

    
}

var thePayrollView : PayrollWebPreview!

class PayrollWebPreview : UIViewController, UIWebViewDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var webView : UIWebView!
    var payrollHTML : PayrollReportHTML!
    
    var periodDates : String!
    var employees : [EmployeePayrollReportModel]!
    
    var HTML : String!
    var docController: UIDocumentInteractionController?
    var loadingUI : NVActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        webView.delegate = self
        createReportAsHTML()
    }
    
    func createReportAsHTML() {
        payrollHTML = PayrollReportHTML()
        if let payrollHTML2 = payrollHTML.renderInvoice(periodDates: periodDates, employees: employees) {
            self.webView.loadHTMLString(payrollHTML2, baseURL: URL(string: payrollHTML.pathToHTMLTemplate!))
            HTML = payrollHTML2
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        thePayrollView = self
         PayrollReportHTML().exportHTMLContentToPDF(HTMLContent: HTML, printFormatter: webView.viewPrintFormatter())
    }
    
    func presentPDF(fileName : String) {
        var docController: UIDocumentInteractionController?
        docController = UIDocumentInteractionController(url: URL(fileURLWithPath: fileName))
        docController!.delegate = self
        docController!.presentPreview(animated: true)
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        let viewController: UIViewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
        return viewController
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.dismiss(animated: true , completion: nil)
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.string(name: "dismissRunTimeReport"), object: nil)
        }
    }
}

class printPayrollToPDF : UIPrintPageRenderer {
    
    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 841.8
    
    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
        
    }
    
}
