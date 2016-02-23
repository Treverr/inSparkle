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
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
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
        var keyList : [String] {
            get {
                return Array(counts.keys)
            }
        }
        let addCellIndexRow = (tableView.numberOfRowsInSection(0) - 1)
        
        if indexPath.section == 0 && indexPath.row == addCellIndexRow {
            let cell = tableView.dequeueReusableCellWithIdentifier("addCell")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("partCell")! as! PartsTableViewCell
            
            let partTitle = keyList[indexPath.row]
            
            cell.partLabel.text = partTitle
            cell.qtyTextField.text = String(counts[partTitle]!)
            cell.qtyTextField.delegate = self
            cell.qtyTextField.tag = indexPath.row
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let addCellIndexRow = (tableView.numberOfRowsInSection(0) - 1)
        if indexPath.row == addCellIndexRow {
            var partTextField : UITextField?
            let addPart = UIAlertController(title: "Add Part", message: "Enter the Part", preferredStyle: .Alert)
            addPart.addTextFieldWithConfigurationHandler({ (textField : UITextField) in
                textField.placeholder = "part"
                partTextField = textField
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
            let add = UIAlertAction(title: "Add", style: .Default, handler: { (action) in
                self.parts.append(partTextField!.text!)
                self.counts.removeAll()
                for item in self.parts {
                    self.counts[item] = (self.counts[item] ?? 0) + 1
                }
//                self.tableView.beginUpdates()
//                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.parts.count - 1, inSection: 0)], withRowAnimation: .Automatic)
//                self.tableView.endUpdates()
                self.tableView.reloadData()
                print(self.parts)
                print(self.counts)
            })
            addPart.addAction(cancel)
            addPart.addAction(add)
            self.presentViewController(addPart, animated: true, completion: nil)
        }
    }
}

extension WorkOrderPartsTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        let row = textField.tag
        let part = parts[row]
        var current = counts[part]
        counts[part] = Int(textField.text!)
        var difference = counts[part]! - current!
        while difference > 0 {
            parts.append(part)
            difference = difference - 1
        }
        while difference < 0 {
            let indexOf = parts.indexOf(part)
            parts.removeAtIndex(indexOf!)
            difference = difference + 1
        }
        print(parts)
        
    }
    
}
