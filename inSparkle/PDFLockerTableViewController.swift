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
    
    override func viewWillAppear(_ animated: Bool) {
        getFiles()
        self.tableView.reloadData()
    }
    
    enum FileSaveError {
        case error17
    }
    
    func renameFileLongPress(_ longPress: UIGestureRecognizer) {
        print(longPress.state)
        if longPress.state == .began {
            let pressPoint : CGPoint = longPress.location(in: self.tableView)
            let indexPath : IndexPath = self.tableView.indexPathForRow(at: pressPoint)!
            
            var renameTextField : UITextField!
            let renameAlert = UIAlertController(title: "Rename File", message: nil, preferredStyle: .alert)
            renameAlert.addTextField(configurationHandler: { (textField) in
                renameTextField = textField
            })
            let saveButton = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                
                let fileManager = FileManager.default
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentsDirectory = paths[0]
                let inboxPath = documentsDirectory + "/PDFLocker"
                let stringPath =  inboxPath + "/" + self.filePaths[(indexPath as NSIndexPath).row]
                let newFileName = renameTextField.text!
                let selectedFile = stringPath
                let selectedFileName = selectedFile.components(separatedBy: "/").last
                let filePath = selectedFile.components(separatedBy: selectedFileName!)[0]
                let newFilePath = filePath + (newFileName.capitalized + ".pdf")
                do {
                    try FileManager.default.moveItem(atPath: selectedFile, toPath: newFilePath)
                } catch let error as Error {
                    switch error._code {
                    case 516:
                        let fileExistAlert = UIAlertController(title: "Error", message: "The file name you specified already exists. Unable to rename", preferredStyle: .alert)
                        let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        fileExistAlert.addAction(okayButton)
                        self.present(fileExistAlert, animated: true, completion: nil)
                    default :
                        break
                    }
                }
                self.getFiles()
                self.tableView.reloadData()
               
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            renameAlert.addAction(cancelButton)
            renameAlert.addAction(saveButton)
            self.present(renameAlert, animated: true, completion: nil)
        }
    }
    
    
    func getFiles() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory + "/PDFLocker"
        do {
            self.filePaths = try fileManager.contentsOfDirectory(atPath: inboxPath)
        } catch {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell")! as UITableViewCell
        
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory + "/PDFLocker"

        let stringPath =  inboxPath + "/" + self.filePaths[(indexPath as NSIndexPath).row]
        let stringArray = stringPath.components(separatedBy: "/")
        let fileName = stringArray.last
//        let documentName = stringPath.componentsSeparatedByString("file://")[1]
        let fileNameWithoutPDF = fileName?.components(separatedBy: ".pdf")[0].capitalized
        var attribs : NSDictionary?
        var createdAt : Date?
        
        let renameLongPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PDFLockerTableViewController.renameFileLongPress(_:)))
        
        do {
            try attribs = FileManager.default.attributesOfItem(atPath: stringPath) as NSDictionary?
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
        
        cell.accessoryType = .disclosureIndicator
        cell.addGestureRecognizer(renameLongPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filePaths == nil {
            return 0
        } else {
            return self.filePaths.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let selection = (indexPath as NSIndexPath).row
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory + "/PDFLocker"
        
        let stringPath =  inboxPath + "/" + self.filePaths[(indexPath as NSIndexPath).row]

        
        let docURL = URL(fileURLWithPath: stringPath)
        var docController : UIDocumentInteractionController!
        docController = UIDocumentInteractionController(url: docURL)
        docController.delegate = self
        docController.presentPreview(animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selection = (indexPath as NSIndexPath).row
            let fileManager = FileManager.default
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let inboxPath = documentsDirectory + "/PDFLocker"
            
            let stringPath =  inboxPath + "/" + self.filePaths[(indexPath as NSIndexPath).row]

            
            do {
                try FileManager.default.removeItem(atPath: stringPath)
            } catch {
                
            }
            self.getFiles()
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func jumpToPDFFile(_ filePath : String) {
        
        let documentPath = filePath.components(separatedBy: "file://")[1]
        
        let docURL = URL(fileURLWithPath: documentPath)
        var docController : UIDocumentInteractionController!
        docController = UIDocumentInteractionController(url: docURL)
        docController.delegate = self
        docController.presentPreview(animated: true)
        
        self.shouldJumpToPDFWithPath = nil
        
    }
    
}

extension PDFLockerTableViewController : UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        let viewController = UIViewController()
        self.present(viewController, animated: true, completion: nil)
        return viewController
    }
    
}
