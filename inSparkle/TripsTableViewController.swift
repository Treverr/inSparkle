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
    
    var mtObjs : [PFObject]!
    var trips = [[NSDate : NSDate]]()
    var totalTime : NSTimeInterval = 0
    var totalHours : Double = 0.0
    var totalMin : Double = 0.0
    
    @IBOutlet weak var totalTimeItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let dateFormatter = NSDateFormatter()
//        var date1 = "01-09-2016 9:00"
//        var date2 = "01-09-2016 10:00"
//        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
//        var newDate1 = dateFormatter.dateFromString(date1)
//        var newDate2 = dateFormatter.dateFromString(date2)
//        
//        let dateArray : [NSDate : NSDate] = [newDate1! : newDate2!]
//        self.trips.append(dateArray)
        
        if mtObjs != nil {
            for mt in mtObjs {
                mt.fetchInBackgroundWithBlock({ (mtObject : PFObject?, error : NSError?) in
                    if error == nil {
                        let index = self.mtObjs.indexOf(mt)
                        self.mtObjs[index!] = mtObject!
                        let trips = mtObject!.objectForKey("trips") as! [[NSDate : NSDate]]
                        self.trips.appendContentsOf(trips)
                    }
                })
            }
        }
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
        
        let trips = trip.first
        
        let start = trips!.0
        let end = trips!.1
        let diff = end.timeIntervalSinceDate(start)
        totalTime = totalTime + diff
        print(diff)
        let hours = (diff / 60) / 60
        self.totalHours = self.totalHours + hours
        let min = (hours * 60) * 60 - diff
        self.totalMin = self.totalMin + min
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        let startString = dateFormatter.stringFromDate(start)
        let endString = dateFormatter.stringFromDate(end)
        
        cell.textLabel!.text = startString + " - " + endString
        cell.detailTextLabel!.text = String(Int(hours)) + "h " + String(Int(min)) + "m"
        totalTimeItem.title = String("Total Time: \(Int(self.totalHours))h \(Int(self.totalMin))m")
        
        return cell
    }

    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
