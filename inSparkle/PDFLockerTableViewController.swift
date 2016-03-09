//
//  PDFLockerTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/8/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class PDFLockerTableViewController: UITableViewController {
    
    var filePaths : [NSURL]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PDF Locker"
        self.tableView.allowsSelectionDuringEditing = false

    }
    
    override func viewWillAppear(animated: Bool) {
        getFiles()
    }
    
    func getFiles() {
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory.stringByAppendingString("/Inbox")
        
        do {
            self.filePaths = try fileManager.contentsOfDirectoryAtURL(NSURL(string: inboxPath)!, includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants)
        } catch {
            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("fileCell")! as UITableViewCell
        
        let stringPath = String(self.filePaths[indexPath.row])
        let stringArray = stringPath.componentsSeparatedByString("/")
        let fileName = stringArray.last
        let documentName = stringPath.componentsSeparatedByString("file://")[1]
        let fileNameWithoutPDF = fileName?.componentsSeparatedByString(".pdf")[0].capitalizedString
        var attribs : NSDictionary?
        var createdAt : NSDate?
        
        do {
            try attribs = NSFileManager.defaultManager().attributesOfItemAtPath(documentName)
        } catch {
            print(error)
        }
        
        
        cell.textLabel?.text = fileNameWithoutPDF!
        
        if let _attr = attribs {
            createdAt = _attr.fileCreationDate();
        } else {
            createdAt = nil
        }
        
        if createdAt != nil {
            cell.detailTextLabel?.text = GlobalFunctions().stringFromDateShortTimeShortDate(createdAt!)
        }
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filePaths == nil {
            return 0
        } else {
           return self.filePaths.count
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selection = indexPath.row
        let documentPath = String(self.filePaths[selection]).componentsSeparatedByString("file://")[1]
        
        let docURL = NSURL.fileURLWithPath(documentPath)
        var docController : UIDocumentInteractionController!
        docController = UIDocumentInteractionController(URL: docURL)
        docController.delegate = self
        docController.presentPreviewAnimated(true)
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let selection = indexPath.row
            let documentPath = String(self.filePaths[selection]).componentsSeparatedByString("file://")[1]
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(documentPath)
            } catch {
                
            }
            self.getFiles()
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    func jumpToPDFFile(filePath : String) {
        
        let documentPath = filePath.componentsSeparatedByString("file://")[1]
        
        let docURL = NSURL.fileURLWithPath(documentPath)
        var docController : UIDocumentInteractionController!
        docController = UIDocumentInteractionController(URL: docURL)
        docController.delegate = self
        docController.presentPreviewAnimated(true)
        
    }
    
}

extension PDFLockerTableViewController : UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        let viewController = UIViewController()
        self.presentViewController(viewController, animated: true, completion: nil)
        return viewController
    }
    
}
