//
//  LaborPartsTableViewController.swift
//
//
//  Created by Trever on 2/23/16.
//
//

import UIKit

class LaborPartsTableViewController : UITableViewController {
    
    var labor = [String]()
    var counts : [String : Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in labor {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resize"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("laborCell") as! LaborPartsTableViewCell
            let partTitle = keyList[indexPath.row]
            
            cell.laborPartTitle.text = partTitle
            cell.qty.text = String(counts[partTitle]!)
            cell.qty.delegate = self
            cell.qty.tag = indexPath.row
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let addCellIndexRow = (tableView.numberOfRowsInSection(0) - 1)
        if indexPath.row == addCellIndexRow {
            var laborTextField : UITextField?
            let addPart = UIAlertController(title: "Add Labor", message: "Enter the labor.", preferredStyle: .Alert)
            addPart.addTextFieldWithConfigurationHandler({ (textField : UITextField) in
                textField.placeholder = "labor"
                laborTextField = textField
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
            let add = UIAlertAction(title: "Add", style: .Default, handler: { (action) in
                self.labor.append(laborTextField!.text!)
                self.counts.removeAll()
                for item in self.labor {
                    self.counts[item] = (self.counts[item] ?? 0) + 1
                }
                self.tableView.reloadData()
                print(self.labor)
                print(self.counts)
                self.tableView.setNeedsDisplay()
                self.preferredContentSize = self.tableView.contentSize
                
            })
            addPart.addAction(cancel)
            addPart.addAction(add)
            self.presentViewController(addPart, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveLabor(sender : AnyObject) {
        
    }
    
    @IBAction func cancel(sender : AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resize() {
        self.preferredContentSize = self.view.intrinsicContentSize()
    }
    
}

extension LaborPartsTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let row = textField.tag
        let part = labor[row]
        var current = counts[part]
        counts[part] = Int(textField.text!)
        var difference = counts[part]! - current!
        while difference > 0 {
            labor.append(part)
            difference = difference - 1
        }
        while difference < 0 {
            let indexOf = labor.indexOf(part)
            labor.removeAtIndex(indexOf!)
            difference = difference + 1
        }
        print(labor)
        
    }
    
}