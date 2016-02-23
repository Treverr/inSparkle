//
//  WorkOrderPartsTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class WorkOrderPartsTableViewController: UITableViewController {
    
    var parts = ["dildo", "penis", "dildo"]
    var counts : [String:Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in parts {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return counts.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let addCellIndexRow = (tableView.numberOfRowsInSection(0) - 1)
        
        if indexPath.section == 0 && indexPath.row == addCellIndexRow {
            let cell = tableView.dequeueReusableCellWithIdentifier("addCell")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("partCell")! as! PartsTableViewCell
            
            let partTitle = parts[indexPath.row]
            
            cell.partLabel.text = partTitle
            cell.qtyLabel.text = String(counts[partTitle]!)
            cell.addQty.tag = indexPath.row
            cell.addQty.addTarget(self, action: Selector("addQty:"), forControlEvents: .TouchUpInside)
            cell.subQty.tag = indexPath.row
            cell.subQty.addTarget(self, action: Selector("subQty:"), forControlEvents: .TouchUpInside)
            
            return cell
        }
    }
    
    func addQty(sender : UIButton) {
        let row = sender.tag
        let part = parts[row]
        let indexPaths = [NSIndexPath(forRow: row, inSection: 0)]
        parts.append(part)
        print(counts[part])
        counts[part] = counts[part]! + 1
        print(counts[part])
        self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func subQty(sender : UIButton) {
        
    }

}
