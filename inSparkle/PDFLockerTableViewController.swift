//
//  PDFLockerTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/8/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class PDFLockerTableViewController: UITableViewController {
    
    var filePaths : [String]!
    var shouldJumpToPDFWithPath : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PDF Locker"
        self.tableView.allowsSelectionDuringEditing = false
        
        if shouldJumpToPDFWithPath != nil {
            jumpToPDFFile(self.shouldJumpToPDFWithPath!)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getFiles()
    }
    
    enum FileSaveError {
        case Error17
    }
    
    func renameFileLongPress(longPress: UIGestureRecognizer) {
        print(longPress.state)
        if longPress.state == .Began {
            var pressPoint : CGPoint = longPress.locationInView(self.tableView)
            var indexPath : NSIndexPath = self.tableView.indexPathForRowAtPoint(pressPoint)!
            
            var renameTextField : UITextField!
            var renameAlert = UIAlertController(title: "Rename File", message: nil, preferredStyle: .Alert)
            renameAlert.addTextFieldWithConfigurationHandler({ (textField) in
                renameTextField = textField
            })
            let saveButton = UIAlertAction(title: "Save", style: .Default, handler: { (action) in
                
                let fileManager = NSFileManager.defaultManager()
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsDirectory = paths[0]
                let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")
                let stringPath =  inboxPath + "/" + self.filePaths[indexPath.row]
                let newFileName = renameTextField.text!
                let selectedFile = stringPath
                let selectedFileName = selectedFile.componentsSeparatedByString("/").last
                let filePath = selectedFile.componentsSeparatedByString(selectedFileName!)[0]
                let newFilePath = filePath.stringByAppendingString(newFileName.capitalizedString + ".pdf")
                do {
                    try NSFileManager.defaultManager().moveItemAtPath(selectedFile, toPath: newFilePath)
                } catch let error as NSError {
                    switch error.code {
                    case 516:
                        let fileExistAlert = UIAlertController(title: "Error", message: "The file name you specified already exists. Unable to rename", preferredStyle: .Alert)
                        let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                        fileExistAlert.addAction(okayButton)
                        self.presentViewController(fileExistAlert, animated: true, completion: nil)
                    default :
                        break
                    }
                }
                self.getFiles()
                self.tableView.reloadData()
               
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            renameAlert.addAction(cancelButton)
            renameAlert.addAction(saveButton)
            self.presentViewController(renameAlert, animated: true, completion: nil)
        }
    }
    
    
    func getFiles() {
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")
        
        do {
            self.filePaths = try fileManager.contentsOfDirectoryAtPath(inboxPath)
        } catch {
            
        }
        print(self.filePaths)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("fileCell")! as UITableViewCell
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")

        let stringPath =  inboxPath + "/" + self.filePaths[indexPath.row]
        let stringArray = stringPath.componentsSeparatedByString("/")
        let fileName = stringArray.last
//        let documentName = stringPath.componentsSeparatedByString("file://")[1]
        let fileNameWithoutPDF = fileName?.componentsSeparatedByString(".pdf")[0].capitalizedString
        var attribs : NSDictionary?
        var createdAt : NSDate?
        
        let renameLongPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("renameFileLongPress:"))
        
        do {
            try attribs = NSFileManager.defaultManager().attributesOfItemAtPath(stringPath)
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
        cell.addGestureRecognizer(renameLongPress)
        
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
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")
        
        let stringPath =  inboxPath + "/" + self.filePaths[indexPath.row]

        
        let docURL = NSURL.fileURLWithPath(stringPath)
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
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory = paths[0]
            let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")
            
            let stringPath =  inboxPath + "/" + self.filePaths[indexPath.row]

            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(stringPath)
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
        
        self.shouldJumpToPDFWithPath = nil
        
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
