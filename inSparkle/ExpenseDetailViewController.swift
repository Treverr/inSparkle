//
//  ExpenseDetailViewController.swift
//  inSparkle
//
//  Created by Trever on 3/21/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import Foundation
import UIKit
import Parse
import NVActivityIndicatorView
import QuickLook

class ExpenseDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var logData = [ExpenseLog]()
    var additionalAttachments = [ExpenseAdditionalAttachments]()
    var attachedReceipt : UIImage!
    var expenseObject : ExpenseItem!
    
    let imageTypes = ["png", "tiff", "tif", "jpeg", "jpg", "gif", "bmp", "BMPf"]
    
    var documentController : UIDocumentInteractionController!
    
    var loadingIndicator : NVActivityIndicatorView!
    var loadingIndicatorBG : UIView!
    var loadingIndicatorUILabel : UILabel!
    
    @IBOutlet weak var dollarAmountLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var referenceHeader: UILabel!
    
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var logTableView: UITableView!
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var addAttachmentButton: UIButton!
    
    @IBOutlet weak var blueView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dollarAmountLabel.text = ""
        merchantNameLabel.text = ""
        refLabel.text = ""
        referenceHeader.isHidden = true
        paymentMethodLabel.text = ""
        
        logTableView.delegate = self
        logTableView.dataSource = self
        
        attachmentCollectionView.delegate = self
        attachmentCollectionView.dataSource = self
        
        let flagGesture = UITapGestureRecognizer(target: self, action: #selector(flagUnflag))
        flagGesture.delegate = self
        flagGesture.numberOfTapsRequired = 1
        self.flagImageView.addGestureRecognizer(flagGesture)
        self.flagImageView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(getDetails), name: Notification.string(name: "ExpenseDetails"), object: nil)
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
    }
    
    func createLoadingIndicator() {
        loadingIndicatorBG = UIView(frame: CGRect(x: 0, y: 0, width: self.blueView.bounds.width, height: self.view.bounds.height))
        loadingIndicatorBG.layer.opacity = 0.25
        loadingIndicatorBG.backgroundColor = UIColor.black
        
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        loadingIndicator.center = self.view.center
        loadingIndicator.color = UIColor.white
        loadingIndicator.type = .ballClipRotate
        
        loadingIndicatorUILabel = UILabel(frame: CGRect(x: 0, y: 0, width: (loadingIndicator.frame.width / 2), height: (loadingIndicator.frame.height / 2)))
        loadingIndicatorUILabel.text = "Loading..."
        loadingIndicatorUILabel.textColor = UIColor.white
        loadingIndicatorUILabel.center = self.view.center
        loadingIndicatorUILabel.textAlignment = .center
        loadingIndicatorUILabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        
        startLoadingIndicator()
    }
    
    func startLoadingIndicator() {
        self.view.addSubview(loadingIndicatorBG)
        self.loadingIndicatorBG.addSubview(loadingIndicator)
        self.loadingIndicatorBG.addSubview(loadingIndicatorUILabel)
        self.loadingIndicator.startAnimating()
    }
    
    func stopLoadingIndicator() {
        self.loadingIndicatorUILabel.removeFromSuperview()
        self.loadingIndicator.removeFromSuperview()
        self.loadingIndicatorBG.removeFromSuperview()
    }
    
    func getDetails(notification : Notification) {
        createLoadingIndicator()
        let expenseObject = notification.object as! ExpenseItem
        self.expenseObject = expenseObject
        
        if expenseObject.dollarAmount != nil {
            self.dollarAmountLabel.text = formatAmount(number: NSNumber(value: expenseObject.dollarAmount!))
        } else {
            self.dollarAmountLabel.text = "$--.--"
        }
        self.paymentMethodLabel.text = expenseObject.paymentMethod
        self.merchantNameLabel.text = expenseObject.merchantName.name
        
        if expenseObject.reference != nil {
            self.referenceHeader.isHidden = false
            self.refLabel.text = expenseObject.reference
        } else {
            self.referenceHeader.isHidden = true
            self.refLabel.isHidden = true
        }
        
        flagImageView.isHighlighted = expenseObject.isFlagged
        
        if let receiptImage = expenseObject.attachedReceipt {
            receiptImage.getDataInBackground(block: { (attchRecpt, error) in
                if error == nil {
                    let image = UIImage(data: attchRecpt!)
                    self.attachedReceipt = image
                }
            })
        } else {
            self.attachedReceipt = nil
        }
        
        logQuery(expenseObject: expenseObject)
        
        additionalItemsQuery(expenseObject: expenseObject)
        
    }
    
    func logQuery(expenseObject : ExpenseItem) {
        let logQuery = ExpenseLog.query()
        logQuery?.whereKey("expenseObject", equalTo: expenseObject)
        logQuery?.order(byDescending: "createdAt")
        logQuery?.includeKey("employee")
        logQuery?.findObjectsInBackground(block: { (logResults, error) in
            if error == nil {
                self.logData = logResults as! [ExpenseLog]
                self.logTableView.reloadData()
            }
        })
    }
    
    func additionalItemsQuery(expenseObject : ExpenseItem) {
        let additionalAttachmentsQuery = ExpenseAdditionalAttachments.query()
        additionalAttachmentsQuery?.whereKey("expenseItem", equalTo: expenseObject)
        additionalAttachmentsQuery?.findObjectsInBackground(block: { (addtlAttch, error) in
            if error == nil {
                self.additionalAttachments = addtlAttch as! [ExpenseAdditionalAttachments]
                self.attachmentCollectionView.reloadData()
                self.stopLoadingIndicator()
            }
        })
    }
    
    func formatAmount(number:NSNumber) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.currencyGroupingSeparator = ","
        return formatter.string(from: number)!
    }
    
    @IBAction func addAttachmentButton(_ sender: UIButton) {
        var documentTypes = ["com.adobe.pdf"]
        let importMenu = UIDocumentMenuViewController(documentTypes: documentTypes, in: .import)
        importMenu.delegate = self
        importMenu.popoverPresentationController?.sourceView = sender
        importMenu.popoverPresentationController?.sourceRect = sender.bounds
        
        importMenu.addOption(withTitle: "Photo Library", image: UIImage(named: "AddAttachment-PhotLibraryIcon")!, order: .first) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        importMenu.addOption(withTitle: "Take Photo", image: UIImage(named: "AddAttachment-CameraIcon")!, order: .first) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        self.present(importMenu, animated: true) {
            
        }
        
    }
    
    func saveAdditionalAttachmentImage(image : UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let file = PFFile(data: imageData, contentType: MimeType(ext: "jpeg"))
        saveAdditionalFile(file: file)
    }
    
    func saveAdditionalFile(file : PFFile) {
        let fileName = UIAlertController(title: "Filename", message: "Enter a recognizable name for this file", preferredStyle: .alert)
        
        fileName.addTextField { (textField) in
            textField.placeholder = "filename"
            textField.autocapitalizationType = .words
        }
        
        let okay = UIAlertAction(title: "Okay", style: .default) { (alert) in
            if let textFieldText = fileName.textFields?.first?.text {
                
                let attachment = ExpenseAdditionalAttachments()
                attachment.fileName = textFieldText
                
                file.saveInBackground(block: { (success, error) in
                    if success && error == nil {
                        attachment.attachment = file
                        attachment.expenseItem = self.expenseObject
                        attachment.attachedByEmployee = EmployeeData.universalEmployee
                        attachment.saveInBackground(block: { (success2, error2) in
                            if success2 && error2 == nil {
                                let log = ExpenseLog()
                                log.employee = EmployeeData.universalEmployee
                                log.expenseObject = self.expenseObject
                                log.logReason = LogReasons.AttachedFile(fileName: textFieldText)
                                log.saveInBackground(block: { (success, error) in
                                    self.logQuery(expenseObject: self.expenseObject)
                                })
                                self.additionalItemsQuery(expenseObject: self.expenseObject)
                                NotificationCenter.default.post(name: Notification.string(name: "RefreshExpenseList"), object: nil)
                            }
                        })
                    }
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        fileName.addAction(okay)
        fileName.addAction(cancel)
        self.present(fileName, animated: true, completion: nil)
    }
    
    func flagUnflag() {
        self.flagImageView.isHighlighted = !flagImageView.isHighlighted
        self.expenseObject.isFlagged = flagImageView.isHighlighted
        self.expenseObject.saveInBackground()
        
        var logReason : String!
        
        if flagImageView.isHighlighted {
            logReason = LogReasons.Flagged
        } else {
            logReason = LogReasons.Unfalgged
        }
        
        GlobalFunctions.expenseLog(expenseItem: self.expenseObject, logReason: logReason) { (success, error) in
            if error == nil && success {
                self.logQuery(expenseObject: self.expenseObject)
                NotificationCenter.default.post(name: Notification.string(name: "RefreshExpenseList"), object: nil)
            }
        }
    }
    
}

extension ExpenseDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = logTableView.dequeueReusableCell(withIdentifier: "addComment")
            return cell!
        }
        
        let cell = logTableView.dequeueReusableCell(withIdentifier: "logCell") as! ExpenseLogTableViewCell
        let logItem = self.logData[indexPath.row - 1]
        let employee = logItem.employee
        var reason = logItem.logReason
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .none
        dateFormat.doesRelativeDateFormatting = true
        
        var iconView = UIImage()
        
        if logItem.logReason.contains("Attached File: ") {
            reason = "Attached File"
        }
        
        if logItem.logReason.contains("Added Comment") {
            reason = "Added Comment"
        }
        
        iconView = LogIcons.getIcon(reason: reason)
        
        cell.iconImageView.image = iconView
        
        cell.logReasonLabel.text = logItem.logReason
        cell.employeeAndDateLabel.text = employee.firstName + " " + employee.lastName + " | " + dateFormat.string(from: logItem.createdAt!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(12)
        }
        
        return CGFloat(44)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            logComment()
        }
        
        logTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func logComment() {
        let commentAlert = UIAlertController(title: "Add a Comment", message: nil, preferredStyle: .alert)
        commentAlert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "enter comment"
            textField.autocapitalizationType = .words
        })
        let addComment = UIAlertAction(title: "Add Comment", style: .default, handler: { (action) in
            if let comment = commentAlert.textFields?.first?.text {
                
                GlobalFunctions.expenseLog(expenseItem: self.expenseObject, logReason: LogReasons.AddedComment(comment: comment), completion: { (success, error) in
                    if error == nil && success {
                        self.logQuery(expenseObject: self.expenseObject)
                    }
                })
                
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        commentAlert.addAction(cancel)
        commentAlert.addAction(addComment)
        self.present(commentAlert, animated: true, completion: nil)
    }
    
}

extension ExpenseDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.attachedReceipt != nil {
            return self.additionalAttachments.count + 1
        } else {
            return self.additionalAttachments.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.attachedReceipt != nil {
            if indexPath.item == 0 {
                let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "fullImageCell", for: indexPath) as! FullImageCollectionViewCell
                cell.imageView!.image = self.attachedReceipt
                return cell
            } else {
                let attachment = self.additionalAttachments[indexPath.row - 1]
                let fileType = attachment.attachment.url?.components(separatedBy: ".").last!
                
                if fileType != nil {
                    if imageTypes.contains(fileType!) {
                        let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "fullImageCell", for: indexPath) as! FullImageCollectionViewCell
                        attachment.attachment.getDataInBackground(block: { (data, error) in
                            if error == nil {
                                cell.imageView.image = UIImage(data: data!)
                            }
                        })
                        return cell
                        
                    } else {
                        let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentsCollectionViewCell
                        
                        cell.attachmentNameLabel.text = attachment.fileName
                        
                        cell.iconImageView.image = FileType.iconFromType(type: fileType!)
                        
                        cell.layer.borderWidth = 0.5
                        cell.layer.borderColor = Colors.sparkleGreen.cgColor
                        cell.layer.cornerRadius = 2
                        
                        return cell
                    }
                }
            }
        } else {
            let attachment = self.additionalAttachments[indexPath.row]
            let fileType = attachment.attachment.url?.components(separatedBy: ".").last!
            
            if fileType != nil {
                if imageTypes.contains(fileType!) {
                    let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "fullImageCell", for: indexPath) as! FullImageCollectionViewCell
                    attachment.attachment.getDataInBackground(block: { (data, error) in
                        if error == nil {
                            cell.imageView.image = UIImage(data: data!)
                        }
                    })
                    return cell
                    
                } else {
                    let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentsCollectionViewCell
                    
                    cell.attachmentNameLabel.text = attachment.fileName
                    
                    
                    
                    cell.iconImageView.image = FileType.iconFromType(type: fileType!)
                    
                    cell.layer.borderWidth = 0.5
                    cell.layer.borderColor = Colors.sparkleGreen.cgColor
                    cell.layer.cornerRadius = 2
                    
                    return cell
                }
            }
        }
        let cell = self.attachmentCollectionView.dequeueReusableCell(withReuseIdentifier: "attachmentCell", for: indexPath) as! AttachmentsCollectionViewCell
        cell.iconImageView.image = UIImage(named: "ExpenseAttachmentType-Default")
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var temp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        if self.attachedReceipt != nil {
            if indexPath.item == 0 {
                let file = UIImageJPEGRepresentation(self.attachedReceipt, 1.0)
                temp.appendPathComponent(self.expenseObject.attachedReceipt!.name)
                
                try? file?.write(to: temp)
                self.presentPreview(url : temp)
            } else {
                let item = self.additionalAttachments[indexPath.item - 1].attachment
                item.getDataInBackground(block: { (data, error) in
                    if error == nil {
                        temp.appendPathComponent(item.name)
                        try? data?.write(to: temp)
                        self.presentPreview(url : temp)
                    }
                })
                
            }
        } else {
            let item = self.additionalAttachments[indexPath.item].attachment
            item.getDataInBackground(block: { (data, error) in
                if error == nil {
                    temp.appendPathComponent(item.name)
                    try? data?.write(to: temp)
                    self.presentPreview(url : temp)
                }
            })
        }
    }
    
    func presentPreview(url : URL) {
        self.documentController = UIDocumentInteractionController(url: url)
        self.documentController.delegate = self
        self.documentController.presentPreview(animated: true)
    }
    
}

extension ExpenseDetailViewController : UIDocumentInteractionControllerDelegate {
    
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


extension ExpenseDetailViewController : UIDocumentPickerDelegate, UIDocumentMenuDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let fileType = fileName.components(separatedBy: ".").last
            self.saveAdditionalFile(file: PFFile(data: fileData, contentType: MimeType(ext: fileType)))
        } catch {
            
        }
        
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension ExpenseDetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        saveAdditionalAttachmentImage(image: image)
    }
    
}
