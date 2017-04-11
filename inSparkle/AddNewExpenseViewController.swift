//
//  AddNewExpenseViewController.swift
//  inSparkle
//
//  Created by Trever on 3/2/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class AddNewExpenseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dollarAmountLabel: UITextField!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var reimbursableSwitch: UISwitch!
    @IBOutlet weak var referenceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var attachImage : PFFile!
    var expense : ExpenseItem!
    
    var expenseDateAsDate : Date!
    var merchantMerchant : Merchant!
    var categoryAsCategory : ExpenseCategory!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        self.merchantNameLabel.textColor = Colors.placeholderGray
        self.dateLabel.textColor = Colors.placeholderGray
        self.categoryLabel.textColor = Colors.placeholderGray
        self.paymentMethodLabel.textColor = Colors.placeholderGray
        self.referenceTextField.textColor = Colors.placeholderGray
        self.descriptionTextView.textColor = UIColor.black
        
        self.referenceTextField.delegate = self
        
        self.reimbursableSwitch.setOn(false, animated: false)
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        self.dollarAmountLabel.addTarget(self, action: #selector(dollarTextFieldDidChange), for: .editingChanged)
        
        let selectMerchantTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectMerchant))
        selectMerchantTapGestureRecognizer.numberOfTapsRequired = 1
        selectMerchantTapGestureRecognizer.isEnabled = true
        selectMerchantTapGestureRecognizer.delegate = self
        self.merchantNameLabel.isUserInteractionEnabled = true
        self.merchantNameLabel.addGestureRecognizer(selectMerchantTapGestureRecognizer)
        
        let selectExpenseDateTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectExpenseDate))
        selectExpenseDateTapGesture.numberOfTapsRequired = 1
        selectExpenseDateTapGesture.isEnabled = true
        selectExpenseDateTapGesture.delegate = self
        self.dateLabel.isUserInteractionEnabled = true
        self.dateLabel.addGestureRecognizer(selectExpenseDateTapGesture)
        
        let selectCategoryTapGesure = UITapGestureRecognizer(target: self, action: #selector(selectCategory))
        selectCategoryTapGesure.numberOfTapsRequired = 1
        selectCategoryTapGesure.isEnabled = true
        selectCategoryTapGesure.delegate = self
        self.categoryLabel.isUserInteractionEnabled = true
        self.categoryLabel.addGestureRecognizer(selectCategoryTapGesure)
        
        let selectPaymentTapGesure = UITapGestureRecognizer(target: self, action: #selector(selectPaymentType))
        selectPaymentTapGesure.numberOfTapsRequired = 1
        selectPaymentTapGesure.isEnabled = true
        selectPaymentTapGesure.delegate = self
        self.paymentMethodLabel.isUserInteractionEnabled = true
        self.paymentMethodLabel.addGestureRecognizer(selectPaymentTapGesure)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMerchantName), name: NSNotification.Name(rawValue: "UpdateMerchantName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateExpenseDate), name: NSNotification.Name(rawValue: "UpdateExpenseDate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategoryName), name: NSNotification.Name(rawValue: "UpdateCategoryName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePaymentType), name: NSNotification.Name(rawValue: "UpdatePaymentName"), object: nil)
    }
    
    func dollarTextFieldDidChange() {
        
        if let amountString = dollarAmountLabel.text?.currencyInputFormatting() {
            dollarAmountLabel.text = amountString
        }
    }
    
    func selectMerchant(gesture:UIGestureRecognizer) {
        let viewController = UIStoryboard(name: "Expense", bundle: nil).instantiateViewController(withIdentifier: "MerchantSelectTableNav")
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self.merchantNameLabel
        viewController.popoverPresentationController?.sourceRect = CGRect(x: self.merchantNameLabel.bounds.maxX, y: self.merchantNameLabel.bounds.midY, width: 0, height: 0)
        viewController.popoverPresentationController?.permittedArrowDirections = .left
        viewController.preferredContentSize = CGSize(width: 300, height: 0)
        present(viewController, animated: true) {
            
        }
    }
    
    func selectExpenseDate(gesture:UIGestureRecognizer) {
        let viewController = UIStoryboard(name: "Expense", bundle: nil).instantiateViewController(withIdentifier: "SelectDateNav") as! UINavigationController
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self.dateLabel
        viewController.popoverPresentationController?.sourceRect = CGRect(x: self.dateLabel.bounds.maxX, y: self.dateLabel.bounds.midY, width: 0, height: 0)
        viewController.popoverPresentationController?.permittedArrowDirections = .left
        present(viewController, animated: true) {
            
        }
        
    }
    
    func selectCategory(gesture:UIGestureRecognizer) {
        let viewController = UIStoryboard(name: "Expense", bundle: nil).instantiateViewController(withIdentifier: "categorySelectNav") as! UINavigationController
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self.categoryLabel
        viewController.popoverPresentationController?.sourceRect = CGRect(x: self.categoryLabel.bounds.maxX, y: self.categoryLabel.bounds.midY, width: 0, height: 0)
        viewController.popoverPresentationController?.permittedArrowDirections = .left
        viewController.preferredContentSize = CGSize(width: 300, height: 0)
        present(viewController, animated: true) {
            
        }
    }
    
    func selectPaymentType(gesture:UIGestureRecognizer) {
        let viewController = UIStoryboard(name: "Expense", bundle: nil).instantiateViewController(withIdentifier: "paymentSelectNav") as! UINavigationController
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self.paymentMethodLabel
        viewController.popoverPresentationController?.sourceRect = CGRect(x: self.paymentMethodLabel.bounds.maxX, y: self.paymentMethodLabel.bounds.midY, width: 0, height: 0)
        viewController.popoverPresentationController?.permittedArrowDirections = .left
        viewController.preferredContentSize = CGSize(width: 300, height: 0)
        present(viewController, animated: true) {
            
        }
    }
    
    func updateMerchantName(notification : Notification) {
        if let merch = notification.object as? Merchant {
            self.merchantNameLabel.text = merch.name
            self.merchantNameLabel.textColor = UIColor.black
            self.merchantMerchant = merch
        }
    }
    
    func updateExpenseDate(notification : Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = SparkleTimeZone.timeZone
        dateFormatter.doesRelativeDateFormatting = true
        self.dateLabel.text = dateFormatter.string(from: notification.object as! Date)
        self.dateLabel.textColor = UIColor.black
        self.expenseDateAsDate = notification.object as! Date
    }
    
    func updateCategoryName(notification : Notification) {
        if let category = notification.object as? ExpenseCategory {
            self.categoryLabel.text = category.name
            self.categoryLabel.textColor = UIColor.black
            self.categoryAsCategory = category
        }
    }
    
    func updatePaymentType(notification : Notification) {
        if let payment = notification.object as? String {
            self.paymentMethodLabel.text = payment
            self.paymentMethodLabel.textColor = UIColor.black
        }
    }
    
    @IBAction func attachAction(_ sender: Any) {
        imagePicker.allowsEditing = true
        
        let typePicker = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: {
                
            })
        }
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: {
                
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        
        typePicker.addAction(photoLibrary)
        typePicker.addAction(camera)
        typePicker.addAction(cancel)
        present(typePicker, animated: true) {
            
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        if merchantNameLabel.text == "Tap to select" {
            self.merchantNameLabel.textColor = UIColor.red
        }
        
        if dateLabel.text == "Tap to select" {
            self.dateLabel.textColor = UIColor.red
        }
        
        if paymentMethodLabel.text == "Tap to select" {
            self.paymentMethodLabel.textColor = UIColor.red
        }
        
        if merchantNameLabel.textColor == UIColor.red || dateLabel.textColor == UIColor.red || dollarAmountLabel.textColor == UIColor.red || paymentMethodLabel.textColor == UIColor.red {
            return
        }
        
        let saveUI = savingAnimation()
        saveUI.startAnimating()
        
        let expenseItem = ExpenseItem()
        expenseItem.merchantName = self.merchantMerchant
        expenseItem.expenseDate = self.expenseDateAsDate
        expenseItem.category = self.categoryAsCategory
        
        var dollaBills = self.dollarAmountLabel.text?.components(separatedBy: "$").last
        dollaBills = dollaBills!.replacingOccurrences(of: ",", with: "")
        expenseItem.dollarAmount = Double(dollaBills!)!
        
        expenseItem.paymentMethod = self.paymentMethodLabel.text!
        expenseItem.reimbursable = self.reimbursableSwitch.isOn
        if self.referenceTextField.text != "Tap to enter" {
            expenseItem.reference = self.referenceTextField.text
        }
        expenseItem.isFlagged = false
        
        if !descriptionTextView.text.isEmpty {
            expenseItem.descriptionNote = self.descriptionTextView.text
        }
        
        if self.attachImage != nil {
            self.attachImage.saveInBackground { (success, error) in
                if error == nil && success {
                    expenseItem.attachedReceipt = self.attachImage
                    expenseItem.saveInBackground(block: { (success, error) in
                        if error == nil && success {
                            
                            saveUI.stopAnimating()
                            
                            self.logCreatedExpense(item: expenseItem)
                            
                            self.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshExpenseList"), object: nil)
                            })
                        }
                    })
                }
            }
        } else {
            saveUI.stopAnimating()
            logCreatedExpense(item: expenseItem)
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshExpenseList"), object: nil)
            })
        }
    }
    
    func logCreatedExpense(item : ExpenseItem) {
        let log = ExpenseLog()
        log.employee = EmployeeData.universalEmployee
        log.expenseObject = item
        log.logReason = LogReasons.CreatedExpense
        log.saveInBackground()
    }
    
    func savingAnimation() -> NVActivityIndicatorView {
        let x = (self.view.frame.size.width / 2)
        let y = (self.view.frame.size.height / 2)
        
        let background = UIView()
        background.backgroundColor = UIColor.black
        background.frame = CGRect(x: 0, y: 0, width: 247, height: 247)
        background.center = self.view.center
        background.layer.cornerRadius = 5
        background.layer.opacity = 0.75
        
        let frame = CGRect(x: 0, y: 0, width: 247, height: 247)
        let savingUI = NVActivityIndicatorView(frame: frame)
        savingUI.center = background.center
        
        let label = UILabel()
        label.frame = background.frame
        label.center = CGPoint(x: background.center.x, y: background.center.y)
        label.text = "Saving Expense..."
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        
        self.view.addSubview(background)
        self.view.addSubview(savingUI)
        self.view.addSubview(label)
        
        savingUI.type = .ballClipRotate
        savingUI.color = .white
        
        return savingUI
    }
}

extension AddNewExpenseViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.referenceTextField {
            if textField.text == "Tap to enter" {
                textField.text = ""
                textField.textColor = UIColor.black
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == self.referenceTextField {
            if textField.text == ""  {
                textField.text = "Tap to enter"
                textField.textColor = Colors.placeholderGray
            }
        }
    }
    
}

extension AddNewExpenseViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.receiptImageView.contentMode = .scaleAspectFit
            self.receiptImageView.image = pickedImage
            self.attachImage = PFFile(data: UIImageJPEGRepresentation(pickedImage, 1.0)!, contentType:  "image/jpeg")
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
