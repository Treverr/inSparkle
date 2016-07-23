//
//  WorkOrderPartsTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/22/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class WorkOrderPartsTableViewController: UITableViewController {
    
    var parts = [String]()
    var counts : [String:Int] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in parts {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resize"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return counts.count + 1
    }
    
    @IBAction func saveParts(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("UpdatePartsArray", object: self.parts)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resize() {
        self.preferredContentSize = self.view.intrinsicContentSize()
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
                self.tableView.reloadData()
                print(self.parts)
                print(self.counts)
                self.tableView.setNeedsDisplay()
                self.preferredContentSize = self.tableView.contentSize
                
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
