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
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LaborPartsTableViewController.resize), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counts.count + 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "laborCell") as! LaborPartsTableViewCell
            let partTitle = keyList[(indexPath as NSIndexPath).row]
            
            cell.laborPartTitle.text = partTitle
            cell.qty.text = String(counts[partTitle]!)
            cell.qty.delegate = self
            cell.qty.tag = (indexPath as NSIndexPath).row
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let addCellIndexRow = (tableView.numberOfRows(inSection: 0) - 1)
        if (indexPath as NSIndexPath).row == addCellIndexRow {
            var laborTextField : UITextField?
            let addPart = UIAlertController(title: "Add Labor", message: "Enter the labor.", preferredStyle: .alert)
            addPart.addTextField(configurationHandler: { (textField : UITextField) in
                textField.placeholder = "labor"
                laborTextField = textField
            })
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            let add = UIAlertAction(title: "Add", style: .default, handler: { (action) in
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
            self.present(addPart, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveLabor(_ sender : AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateLaborArray"), object: self.labor)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender : AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func resize() {
        self.preferredContentSize = self.view.intrinsicContentSize
    }
    
}

extension LaborPartsTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let row = textField.tag
        let part = labor[row]
        let current = counts[part]
        counts[part] = Int(textField.text!)
        var difference = counts[part]! - current!
        while difference > 0 {
            labor.append(part)
            difference = difference - 1
        }
        while difference < 0 {
            let indexOf = labor.index(of: part)
            labor.remove(at: indexOf!)
            difference = difference + 1
        }
        print(labor)
        
    }
    
}
