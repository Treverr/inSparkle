//
//  ComposeMessageTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/27/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ComposeMessageTableViewController: UITableViewController {
    
    var isNewMessage : Bool = true
    
    @IBOutlet var dateTimeOfMessage: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var signedLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var addImage: UIImageView!
    
    var selectedEmployee : Employee?
    var formatter = NSDateFormatter()
    
    override func viewWillAppear(animated: Bool) {
        let employeeData = PFUser.currentUser()?.objectForKey("employee") as! Employee
        print(employeeData)
        employeeData.fetchIfNeededInBackgroundWithBlock { (employee : PFObject?, error : NSError?) -> Void in
            if error == nil {
                self.signedLabel.text = "Signed: " + employeeData.firstName + " " + employeeData.lastName
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recipientLabel.text = "Add Recipient"
        
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        dateTimeOfMessage.text! = formatter.stringFromDate(NSDate())
        
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isNewMessage == false && indexPath.section == 1 && indexPath.row == 0 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
    }
    
    
    @IBAction func saveButton(sender: AnyObject) {
        
        if isNewMessage == true {
            let messObj = Messages()
            messObj.dateTimeMessage = NSDate()
            messObj.recipient = selectedEmployee!
            messObj.messageFromName = nameLabel.text!
            messObj.messageFromPhone = phoneLabel.text!
            if (addressLabel.text?.isEmpty) == false {
                messObj.messageFromAddress = addressLabel.text!
            }
            messObj.theMessage = messageTextView.text!
            messObj.signed = PFUser.currentUser()!
            
            
        }
    }
    
    @IBAction func returnFromEmployeeSelection(segue : UIStoryboardSegue) {
        let recipName = selectedEmployee!.firstName + " " + selectedEmployee!.lastName
        recipientLabel.text = "To: " + recipName
        addImage.hidden = true
    }

}
