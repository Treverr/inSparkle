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
    
    func displayInfo(_ sentObject : PFObject) {
        print("Passed: \(sentObject)")
        let theObject = sentObject
        
        let theCustomerName = theObject.value(forKey: "customerName") as! String
        customerName.textColor = UIColor.black
        let theDate = theObject.value(forKey: "date") as? Date
        let theDateString : String?
        if theDate != nil {
            theDateString = stringFromDate(theDate!)
            dateLabel.text = theDateString!
            dateLabel.textColor = UIColor.black
        } else {
            dateLabel.text = "No Date Set"
            dateLabel.textColor = Colors.placeholderGray
        }
        let location = theObject.value(forKey: "location") as! String
        locationLabel.textColor = UIColor.black
        let serial = theObject.value(forKey: "serial") as? String
        serialTextField.textColor = UIColor.black
        let category = theObject.value(forKey: "category")
        let employee = theObject.value(forKey: "enteredBy") as! PFUser
        print(employee)
        
        
        self.customerName.text? = theCustomerName
        if serial != nil {
            self.serialTextField.text = serial!
        }
        self.locationLabel.text = location
        
        self.employeeName.text = getEmployeeInfo(employee.objectId!)
        employeeName.textColor = UIColor.black
        
        self.navigationItem.title = category as! String
        
    }
    
    func stringFromDate(_ theDate : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.none
        formatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
        let dateString = formatter.string(from: theDate)
        
        return dateString
    }
    
    func getEmployeeInfo(_ emp : String) -> String {
        var user : PFObject!
        let userQuery = PFUser.query()
        userQuery?.whereKey("objectId", equalTo: emp)
        do {
            user = try userQuery?.getFirstObject()
        } catch {
            "error"
        }
        let username = user.value(forKey: "username") as! String
        
        return "Entered By: " + username.capitalized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSOI" {
            DataManager.isEditingSOIbject = true
        }
    }
}
