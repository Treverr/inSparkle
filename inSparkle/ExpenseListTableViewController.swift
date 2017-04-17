//
//  ExpenseListTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/1/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Parse

class ExpenseListTableViewController: UITableViewController {
    
    var tableData = [[ExpenseItem]]()
    var currentSelect : IndexPath!
    
    var flagSwipe : MGSwipeButton?
    var deleteSwipe : MGSwipeButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getExpenses()
        swipeButtons()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getExpenses), name: Notification.Name(rawValue: "RefreshExpenseList"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableData[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let first = self.tableData[section].first!
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .none
        
        return dateFormat.string(from: first.expenseDate)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.tableData[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        cell.expenseDate.text! = dateFormatter.string(from: item.expenseDate)
        cell.merchantName.text! = item.merchantName.name
        if item.dollarAmount != nil {
            cell.expenseCost.text! = formatAmount(number: NSNumber(value: item.dollarAmount!))
        } else {
            cell.expenseCost.text = "$--.--"
        }
        
        
        cell.leftButtons = [self.flagSwipe!]
        cell.rightButtons = [self.deleteSwipe!]
        
        if item.attachedReceipt != nil {
            cell.attachmentImage.isHighlighted = true
        }
        
        cell.flagImage.isHighlighted = item.isFlagged
        
        let expenseQuery = ExpenseAdditionalAttachments.query()
        expenseQuery?.whereKey("expenseItem", equalTo: item)
        var error : NSError?
        let count = expenseQuery?.countObjects(&error)
        
        if count! > 0 {
            cell.attachmentImage.isHighlighted = true
        }
        
        
        return cell
    }
    
    func formatAmount(number:NSNumber) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.currencyGroupingSeparator = ","
        return formatter.string(from: number)!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        
        if self.currentSelect != nil {
            if self.currentSelect == indexPath {
                self.tableView.selectRow(at: self.currentSelect, animated: false, scrollPosition: .none)
            }
        } else {
            let first = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: first, animated: false, scrollPosition: .none)
            self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: first)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func swipeButtons() {
        self.flagSwipe = MGSwipeButton(title: "", icon: UIImage(named: "SwipCell-Flag"), backgroundColor: UIColor.red, callback: { (cell) -> Bool in
            let indexPath = self.tableView.indexPath(for: cell)
            let item = self.tableData[indexPath!.section][indexPath!.row]
            
            item.isFlagged = !item.isFlagged
            
            var logReason : String!
            
            if item.isFlagged {
                logReason = LogReasons.Flagged
            } else {
                logReason = LogReasons.Unfalgged
            }

            
            GlobalFunctions.expenseLog(expenseItem: item, logReason: logReason, completion: { (success, error) in
                if error == nil && success {
                    self.currentSelect = self.tableView.indexPathForSelectedRow
                    NotificationCenter.default.post(name: Notification.string(name: "RefreshExpenseList"), object: nil)
                }
            })
            
            
            self.getExpenses()
            return true
        })
        
        self.deleteSwipe = MGSwipeButton(title: "Delete", backgroundColor: UIColor.red, callback: { (cell) -> Bool in
            let indexPath = self.tableView.indexPath(for: cell)
            let item = self.tableData[indexPath!.section][indexPath!.row]
            var mgReturn = true
            
            item.deleteInBackground(block: { (success, error) in
                if error == nil && success {
                    let deleteAttach = ExpenseAdditionalAttachments.query()
                    deleteAttach?.whereKey("expenseItem", equalTo: item)
                    deleteAttach?.findObjectsInBackground(block: { (attach, error) in
                        if error == nil {
                            PFObject.deleteAll(inBackground: attach!)
                        }
                    })
                    
                    let logs = ExpenseLog.query()
                    logs?.whereKey("expenseItem", equalTo: item)
                    logs?.findObjectsInBackground(block: { (logItems, error) in
                        if error == nil {
                            PFObject.deleteAll(inBackground: logItems)
                        }
                    })
                    
                    self.currentSelect = nil
                    self.getExpenses()
                } else {
                    mgReturn = false
                }
            })
            return mgReturn
        })
        
    }
    
    func getExpenses() {
        
        self.tableData = [[ExpenseItem]]()
        
        let query = ExpenseItem.query()
        query?.order(byDescending: "expenseDate")
        query?.includeKey("merchantName")
        query?.includeKey("category")
        query?.findObjectsInBackground(block: { (expenseResult, error) in
            if error == nil {
                
                var sectionArray = [ExpenseItem]()
                
                for object in expenseResult as! [ExpenseItem] {
                    if let firstObject = sectionArray.first {
                        if Calendar.current.compare(firstObject.expenseDate, to: object.expenseDate, toGranularity: .day) != .orderedSame {
                            self.tableData.append(sectionArray)
                            sectionArray = [ExpenseItem]()
                        }
                    }
                    
                    sectionArray.append(object)
                }
                
                if sectionArray.count != 0 {
                    self.tableData.append(sectionArray)
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentSelect = indexPath
        
        let item = self.tableData[indexPath.section][indexPath.row]
        NotificationCenter.default.post(name: Notification.string(name: "ExpenseDetails"), object: item)
    }
    
    @IBAction func close(_ sender: Any) {
        self.splitViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewExpense(_ sender: Any) {
        let sb = UIStoryboard(name: "Expense", bundle: nil)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let vc = sb.instantiateViewController(withIdentifier: "iPhoneAddNewExpense") as! UINavigationController
            self.present(vc, animated: true, completion: nil)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let vc = sb.instantiateViewController(withIdentifier: "ipadAddNewExpense") as! UINavigationController
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}
