//
//  PaymentTypeTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/9/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class PaymentTypeTableViewController: UITableViewController {
    
    var paymentTypes : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paymentTypes = PFConfigs.config.object(forKey: "PaymentTypes") as! [String]
        self.preferredContentSize = CGSize(width: 300, height: (self.paymentTypes.count * Int(self.tableView.rowHeight) + 88))
        self.tableView.tableFooterView = UIView()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.paymentTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentNameCell", for: indexPath)
        
        cell.textLabel?.text = self.paymentTypes[indexPath.row]
        self.preferredContentSize = CGSize(width: 300, height: tableView.contentSize.height + 50)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdatePaymentName"), object: cell?.textLabel?.text!)
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
