//
//  TripsTableViewController.swift
//  inSparkle
//
//  Created by Trever on 9/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class TripsTableViewController: UITableViewController {
    
    var workOrder : WorkOrders!
    var trips = [WorkServiceOrderTimeLog]()
    var totalTime : NSTimeInterval = 0
    var totalHours : Double = 0.0
    var totalMin : Double = 0.0
    
    @IBOutlet weak var totalTimeItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(animated: Bool) {
        let object = self.workOrder as! PFObject
        let timeQuery = WorkServiceOrderTimeLog.query()
        print(object.objectId!)
        timeQuery?.whereKey("relatedWorkOrderObjectID", equalTo: object.objectId!)
        timeQuery?.orderByAscending("timeStamp")
        timeQuery?.findObjectsInBackgroundWithBlock({ (results : [PFObject]?, error : NSError?) in
            if error == nil {
                self.trips = results as! [WorkServiceOrderTimeLog]
                let sections = NSIndexSet(index: 0)
                self.tableView.reloadSections(sections, withRowAnimation: .Bottom)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(Double(self.trips.count) / 2, self.trips.count)
        let roundNumber = round(Double(self.trips.count) / 2)
        print(roundNumber)
        return Int(roundNumber)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tripCell")! as UITableViewCell
        let currentRow = self.trips[indexPath.row]
        
        print(indexPath.row)
            
            if currentRow.enter == true {
                
                if indexPath.row + 1 <= self.trips.count {
                    
                    if self.trips[indexPath.row + 1].enter == false {
                        let diff = (self.trips[indexPath.row + 1].timeStamp).timeIntervalSinceDate(currentRow.timeStamp)
                        totalTime += diff
                        let hours = (diff / 60) / 60
                        self.totalHours += hours
                        let min : Double!
                        if hours >= 1 {
                            min = ((hours * 60) * 60) - diff
                        } else {
                            min = diff / 60
                        }
                        self.totalMin += min
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = .ShortStyle
                        dateFormatter.timeStyle = .MediumStyle
                        
                        let start = currentRow.timeStamp
                        let end = self.trips[indexPath.row + 1].timeStamp
                        self.trips.removeAtIndex(indexPath.row + 1)
                        
                        let startString = dateFormatter.stringFromDate(start)
                        let endString = dateFormatter.stringFromDate(end)
                        
                        cell.textLabel!.text = startString + " - " + endString
                        cell.detailTextLabel!.text = String(Int(hours)) + "h " + String(Int(min)) + "m"

                    }
                } else {
                    let start = currentRow.timeStamp
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .ShortStyle
                    dateFormatter.timeStyle = .MediumStyle
                    
                    cell.textLabel?.text = dateFormatter.stringFromDate(start) + " - " + "No Time Out Recorded"
                    cell.detailTextLabel?.text = "N/A"
                }
            } else {
                let end = currentRow.timeStamp
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                dateFormatter.timeStyle = .MediumStyle
                
               cell.textLabel?.text = "No Time In Recorded" + " - " + dateFormatter.stringFromDate(end)
                cell.detailTextLabel?.text = "N/A"
            }
        
        totalTimeItem.title = String("Total Time: \(Int(self.totalHours))h \(Int(self.totalMin))m")
        
        return cell
    }

    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
