//
//  DateDetailTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/31/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class DateDetailTableViewController: UITableViewController {
    
    var selectedDate : NSDate!
    var punches : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        self.navigationItem.title = "Time Punches for " + dateFormatter.stringFromDate(selectedDate)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        getTimePunches()
    }
    
    func getTimePunches() {
        let cal = NSCalendar.currentCalendar()
        let query = TimeClockPunchObj.query()
        query?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        query?.whereKey("timePunched", greaterThan: selectedDate)
        query?.orderByDescending("timePunched")
        query?.whereKey("timePunched", lessThan: cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: self.selectedDate, options: [])!)
        query?.findObjectsInBackgroundWithBlock({ (foundPunches : [PFObject]?, error : NSError?) in
            if error == nil {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .ShortStyle
                
                for punch in foundPunches! {
                    let thePunch = punch as! TimeClockPunchObj
                    if thePunch.relatedTimeCalc == nil {
                        if thePunch.punchOutIn == "in" {
                            let punchString = dateFormatter.stringFromDate(thePunch.timePunched) + " - N/A"
                            self.punches.append(punchString)
                             self.tableView.reloadData()
                        }
                        if thePunch.punchOutIn == "out" {
                            let punchString = "N/A - " + dateFormatter.stringFromDate(thePunch.timePunched)
                            self.punches.append(punchString)
                             self.tableView.reloadData()
                        }
                    }
                    if thePunch.relatedTimeCalc != nil {
                        thePunch.relatedTimeCalc?.fetchInBackgroundWithBlock({ (punchPunch : PFObject?, error : NSError?) in
                            if error == nil {
                                let puncher = punchPunch as! TimePunchCalcObject
                                let punchString = dateFormatter.stringFromDate(puncher.timePunchedIn) + " - " + dateFormatter.stringFromDate(puncher.timePunchedOut)
                                if !self.punches.contains(punchString) {
                                    self.punches.append(punchString)
                                }
                                print(self.punches)
                                 self.tableView.reloadData()
                            }
                        })
                    }
                   
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return punches.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("punchCell")
        cell?.textLabel?.text = punches[indexPath.row]
        
        return cell!
    }


}
