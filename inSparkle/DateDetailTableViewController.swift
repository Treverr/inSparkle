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
    
    var selectedDate : Date!
    var punches : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = SparkleTimeZone.timeZone
        
        self.navigationItem.title = "Time Punches for " + dateFormatter.string(from: selectedDate)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTimePunches()
    }
    
    func getTimePunches() {
        let cal = Calendar.current
        let query = TimeClockPunchObj.query()
        query?.whereKey("employee", equalTo: EmployeeData.universalEmployee)
        query?.whereKey("timePunched", greaterThan: selectedDate)
        query?.order(byDescending: "timePunched")
        query?.whereKey("timePunched", lessThan: (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: self.selectedDate, options: [])!)
        query?.findObjectsInBackground(block: { (foundPunches : [PFObject]?, error : Error?) in
            if error == nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                dateFormatter.timeZone = SparkleTimeZone.timeZone
                
                for punch in foundPunches! {
                    let thePunch = punch as! TimeClockPunchObj
                    if thePunch.relatedTimeCalc == nil {
                        if thePunch.punchOutIn == "in" {
                            let punchString = dateFormatter.string(from: thePunch.timePunched) + " - N/A"
                            self.punches.append(punchString)
                             self.tableView.reloadData()
                        }
                        if thePunch.punchOutIn == "out" {
                            let punchString = "N/A - " + dateFormatter.string(from: thePunch.timePunched)
                            self.punches.append(punchString)
                             self.tableView.reloadData()
                        }
                    }
                    if thePunch.relatedTimeCalc != nil {
                        thePunch.relatedTimeCalc?.fetchInBackground(block: { (punchPunch : PFObject?, error : Error?) in
                            if error == nil {
                                let puncher = punchPunch as! TimePunchCalcObject
                                let punchString = dateFormatter.string(from: puncher.timePunchedIn) + " - " + dateFormatter.string(from: puncher.timePunchedOut)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return punches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "punchCell")
        cell?.textLabel?.text = punches[(indexPath as NSIndexPath).row]
        
        return cell!
    }


}
