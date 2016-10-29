//
//  ReactivePOCTableViewController.swift
//  inSparkle
//
//  Created by Trever on 4/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ReactivePOCTableViewController: UITableViewController {
    
    var inactivePOCs = [ScheduleObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Cancelled POC's"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getInactivePOCs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.inactivePOCs.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let swipeAlert = UIAlertController(title: "Try Swipping from the left", message: "Want to re-activate? Swipe from the right and choose 'Re-Activate'", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        swipeAlert.addAction(okay)
        self.present(swipeAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction : UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Re-Activate") { (action, indexPath : IndexPath) in
            let row = (indexPath as NSIndexPath).row
            let item = self.inactivePOCs[row]
            
            item.isActive = true
            item.saveInBackground()
            self.inactivePOCs.remove(at: row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [editAction]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reactivateCell") as! ReActivePOCTableViewCell
        let indexRow = (indexPath as NSIndexPath).row
        
        cell.configureCell(inactivePOCs[indexRow].customerName, weekStart: inactivePOCs[indexRow].weekStart, weekEnd: inactivePOCs[indexRow].weekEnd, cancelReason: inactivePOCs[indexRow].cancelReason)
        
        return cell
        
    }
    
    func getInactivePOCs() {
        let query = ScheduleObject.query()
        query?.whereKey("isActive", equalTo: false)
        query?.order(byAscending: "weekStart")
        query?.findObjectsInBackground(block: { (inactivePOCs : [PFObject]?, error : Error?) in
            self.inactivePOCs = inactivePOCs as! [ScheduleObject]
            self.tableView.reloadData()
        })
        
    }

}
