//
//  MerchantSelectTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/8/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class MerchantSelectTableViewController: UITableViewController {
    
    var merchantList : [Merchant] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setupNavigationbar(self.navigationController!)
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMerchs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func getMerchs() {
        let merchantQuery = Merchant.query()
        merchantQuery?.order(byAscending: "name")
        merchantQuery?.findObjectsInBackground(block: { (merchants, error) in
            if error == nil {
                self.merchantList = merchants as! [Merchant]
                self.preferredContentSize = CGSize(width: 300, height: (merchants!.count * Int(self.tableView.rowHeight) + 88))
                self.tableView.reloadData()
            }
        })
        
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
        return self.merchantList.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "addMerchant", for: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "merchantNameCell", for: indexPath)
            cell.textLabel?.text = self.merchantList[indexPath.row - 1].name
            self.preferredContentSize = CGSize(width: 300, height: tableView.contentSize.height + 50)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            addNewMerch()
        }
        
        if indexPath.row > 0 {
            let merchantToSend = self.merchantList[indexPath.row - 1]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateMerchantName"), object: merchantToSend)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func addNewMerch() {
        let merchantInput = UIAlertController(title: "Add New Merchant", message: "Enter the merchant name, this will be saved for all users to access", preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add", style: .default) { (_) in
            if let textField = merchantInput.textFields?.first {
                let merch = Merchant()
                merch.name = textField.text!
                merch.saveInBackground(block: { (success, error) in
                    if error == nil {
                        self.getMerchs()
                    }
                })
                
            } else {
                
            }
        }

        merchantInput.addTextField { (textField) in
            textField.placeholder = "name"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        merchantInput.addAction(add)
        merchantInput.addAction(cancel)
        self.present(merchantInput, animated: true, completion: nil)
    }

}
