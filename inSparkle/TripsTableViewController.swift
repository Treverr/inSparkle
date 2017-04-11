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
    var totalTime : TimeInterval = 0
    var totalHours : Double = 0.0
    var totalMin : Double = 0.0
    
    @IBOutlet weak var totalTimeItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let object = self.workOrder as PFObject
        let timeQuery = WorkServiceOrderTimeLog.query()
        print(object.objectId!)
        timeQuery?.whereKey("relatedWorkOrderObjectID", equalTo: object.objectId!)
        timeQuery?.order(byAscending: "timeStamp")
        timeQuery?.findObjectsInBackground(block: { (results : [PFObject]?, error : Error?) in
            if error == nil {
                self.trips = results as! [WorkServiceOrderTimeLog]
                let sections = IndexSet(integer: 0)
                self.tableView.reloadSections(sections, with: .bottom)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(Double(self.trips.count) / 2, self.trips.count)
        let roundNumber = round(Double(self.trips.count) / 2)
        print(roundNumber)
        return Int(roundNumber)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell")! as UITableViewCell
        let currentRow = self.trips[(indexPath as NSIndexPath).row]
        
        print((indexPath as NSIndexPath).row)
            
            if currentRow.enter == true {
                
                if (indexPath as NSIndexPath).row + 1 <= self.trips.count {
                    
                    if self.trips[(indexPath as NSIndexPath).row + 1].enter == false {
                        let diff = (self.trips[(indexPath as NSIndexPath).row + 1].timeStamp).timeIntervalSince(currentRow.timeStamp as Date)
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
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .medium
                        dateFormatter.timeZone = SparkleTimeZone.timeZone
                        
                        let start = currentRow.timeStamp
                        let end = self.trips[(indexPath as NSIndexPath).row + 1].timeStamp
                        self.trips.remove(at: (indexPath as NSIndexPath).row + 1)
                        
                        let startString = dateFormatter.string(from: start as Date)
                        let endString = dateFormatter.string(from: end as Date)
                        
                        cell.textLabel!.text = startString + " - " + endString
                        cell.detailTextLabel!.text = String(Int(hours)) + "h " + String(Int(min)) + "m"

                    }
                } else {
                    let start = currentRow.timeStamp
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .medium
                    dateFormatter.timeZone = SparkleTimeZone.timeZone
                    
                    cell.textLabel?.text = dateFormatter.string(from: start as Date) + " - " + "No Time Out Recorded"
                    cell.detailTextLabel?.text = "N/A"
                }
            } else {
                let end = currentRow.timeStamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .medium
                dateFormatter.timeZone = SparkleTimeZone.timeZone
                
               cell.textLabel?.text = "No Time In Recorded" + " - " + dateFormatter.string(from: end as Date)
                cell.detailTextLabel?.text = "N/A"
            }
        
        totalTimeItem.title = String("Total Time: \(Int(self.totalHours))h \(Int(self.totalMin))m")
        
        return cell
    }

    @IBAction func closeButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
