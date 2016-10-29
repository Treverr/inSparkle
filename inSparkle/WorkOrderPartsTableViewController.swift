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
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WorkOrderPartsTableViewController.resize), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return counts.count + 1
    }
    
    @IBAction func saveParts(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdatePartsArray"), object: self.parts)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func resize() {
        self.preferredContentSize = self.view.intrinsicContentSize
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var keyList : [String] {
            get {
                return Array(counts.keys)
            }
        }
        let addCellIndexRow = (tableView.numberOfRows(inSection: 0) - 1)
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == addCellIndexRow {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCell")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partCell")! as! PartsTableViewCell
            
            let partTitle = keyList[(indexPath as NSIndexPath).row]
            
            cell.partLabel.text = partTitle
            cell.qtyTextField.text = String(counts[partTitle]!)
            cell.qtyTextField.delegate = self
            cell.qtyTextField.tag = (indexPath as NSIndexPath).row
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let addCellIndexRow = (tableView.numberOfRows(inSection: 0) - 1)
        if (indexPath as NSIndexPath).row == addCellIndexRow {
            var partTextField : UITextField?
            let addPart = UIAlertController(title: "Add Part", message: "Enter the Part", preferredStyle: .alert)
            addPart.addTextField(configurationHandler: { (textField : UITextField) in
                textField.placeholder = "part"
                partTextField = textField
            })
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            let add = UIAlertAction(title: "Add", style: .default, handler: { (action) in
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
            self.present(addPart, animated: true, completion: nil)
        }
    }
}

extension WorkOrderPartsTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let row = textField.tag
        let part = parts[row]
        let current = counts[part]
        counts[part] = Int(textField.text!)
        var difference = counts[part]! - current!
        while difference > 0 {
            parts.append(part)
            difference = difference - 1
        }
        while difference < 0 {
            let indexOf = parts.index(of: part)
            parts.remove(at: indexOf!)
            difference = difference + 1
        }
        print(parts)
        
    }
    
}
