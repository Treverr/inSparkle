//
//  EmployeeTimeAwayRequestsTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/3/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class EmployeeTimeAwayRequestsTableViewController: UITableViewController {
    
    var employee : Employee!
    var requests : [TimeAwayRequest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEmployeePending()
        
        self.navigationItem.title = "Pending Time Away Requests"
        
        NotificationCenter.default.addObserver(self, selector: #selector(EmployeeTimeAwayRequestsTableViewController.returnToMainTimeAway), name: NSNotification.Name(rawValue: "returnToMainTimeAway"), object: nil)
        
    }
    
    func returnToMainTimeAway() {
        self.requests.removeAll()
        self.getEmployeePending()
    }
    
    func getEmployeePending() {
        let timeAwayQuery = TimeAwayRequest.query()
        timeAwayQuery?.whereKey("employee", equalTo: self.employee)
        timeAwayQuery?.whereKey("status", equalTo: "Pending")
        timeAwayQuery?.findObjectsInBackground(block: { (req : [PFObject]?, error : Error?) in
            if error == nil {
                self.requests = req as! [TimeAwayRequest]
                self.tableView.reloadData()
                if self.requests.count == 0 {
                    self.performSegue(withIdentifier: "returnToMainTimeAway", sender: nil)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "dateCell")! 
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = SparkleTimeZone.timeZone
        
        var dates : String = ""
        let datesArray = self.requests[(indexPath as NSIndexPath).row].datesRequested
        var onDate : Int = 0
        
        for date in datesArray! {
            dates = dates + "\n" + dateFormatter.string(from: datesArray?[onDate] as! Date)
            onDate = onDate + 1
        }
        
        print(dates)
        
        cell.textLabel?.text = dateFormatter.string(from: datesArray?.firstObject as! Date) + " - " + dateFormatter.string(from: datesArray?.lastObject as! Date)
        cell.detailTextLabel?.text = self.requests[(indexPath as NSIndexPath).row].type
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let row = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            let vc = segue.destination as! UINavigationController
            let reqVC = vc.viewControllers.first as! TimeAwayDetailTableViewController
            reqVC.request = self.requests[row!]
            reqVC.employee = self.employee
        }
    }
    
}
