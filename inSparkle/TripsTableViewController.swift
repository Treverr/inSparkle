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
        
        let timeQuery = WorkServiceOrderTimeLog.query()
        timeQuery?.whereKey("relatedWorkOrder", equalTo: self.workOrder)
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
        return self.trips.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tripCell")! as UITableViewCell
        let trip = self.trips[indexPath.row]
        
        let start = trip.arrive
        let end = trip.departed
        if start != nil && end != nil {
            var diff = end?.timeIntervalSinceDate(start!)
            totalTime = totalTime + diff!
            print(diff)
            let hours = (diff! / 60) / 60
            self.totalHours = self.totalHours + hours
            let min : Double!
            if hours >= 1 {
                min = ((hours * 60) * 60) - diff!
            } else {
                min = diff! / 60
            }
            self.totalMin = self.totalMin + min
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .MediumStyle
            
            let startString = dateFormatter.stringFromDate(start!)
            let endString = dateFormatter.stringFromDate(end!)
            
            cell.textLabel!.text = startString + " - " + endString
            cell.detailTextLabel!.text = String(Int(hours)) + "h " + String(Int(min)) + "m"
        } else if end == nil {
            let start = trip.arrive
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            
            let startString = dateFormatter.stringFromDate(start!)
            
            cell.textLabel?.text = startString + " - " + "No Departure Logged"
            cell.detailTextLabel?.text = nil
        }
    
        

        totalTimeItem.title = String("Total Time: \(Int(self.totalHours))h \(Int(self.totalMin))m")
        
        return cell
    }

    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
