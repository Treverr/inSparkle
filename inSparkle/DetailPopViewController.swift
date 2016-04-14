//
//  DetailPopViewController.swift
//  inSparkle
//
//  Created by Trever on 11/19/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class DetailPopViewController: UITableViewController {
    
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var serialTextField: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    
    var passedObject : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
    
        displayInfo(DataManager.passingObject)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayInfo(sentObject : PFObject) {
        print("Passed: \(sentObject)")
        let theObject = sentObject
        
        let theCustomerName = theObject.valueForKey("customerName") as! String
        customerName.textColor = UIColor.blackColor()
        let theDate = theObject.valueForKey("date") as? NSDate
        let theDateString : String?
        if theDate != nil {
            theDateString = stringFromDate(theDate!)
            dateLabel.text = theDateString!
            dateLabel.textColor = UIColor.blackColor()
        } else {
            dateLabel.text = "No Date Set"
            dateLabel.textColor = Colors.placeholderGray
        }
        let location = theObject.valueForKey("location") as! String
        locationLabel.textColor = UIColor.blackColor()
        let serial = theObject.valueForKey("serial") as? String
        serialTextField.textColor = UIColor.blackColor()
        let category = theObject.valueForKey("category")
        let employee = theObject.valueForKey("enteredBy") as! PFUser
        print(employee)
        
        
        self.customerName.text? = theCustomerName
        if serial != nil {
            self.serialTextField.text = serial!
        }
        self.locationLabel.text = location
        
        self.employeeName.text = getEmployeeInfo(employee.objectId!)
        employeeName.textColor = UIColor.blackColor()
        
        self.navigationItem.title = category as! String
        
    }
    
    func stringFromDate(theDate : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        let dateString = formatter.stringFromDate(theDate)
        
        return dateString
    }
    
    func getEmployeeInfo(emp : String) -> String {
        var user : PFObject!
        let userQuery = PFUser.query()
        userQuery?.whereKey("objectId", equalTo: emp)
        do {
            user = try userQuery?.getFirstObject()
        } catch {
            "error"
        }
        let username = user.valueForKey("username") as! String
        
        return "Entered By: " + username.capitalizedString
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSOI" {
            DataManager.isEditingSOIbject = true
        }
    }
}
