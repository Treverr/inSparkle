//
//  CategorySelectTableViewController.swift
//  inSparkle
//
//  Created by Trever on 3/9/17.
//  Copyright © 2017 Sparkle Pools. All rights reserved.
//

import UIKit

class CategorySelectTableViewController: UITableViewController {
    
    var catList : [ExpenseCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setupNavigationbar(self.navigationController!)
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCategories()
    }
    
    func getCategories() {
        let catQuery = ExpenseCategory.query()
        catQuery?.order(byAscending: "name")
        catQuery?.findObjectsInBackground(block: { (categories, error) in
            if error == nil {
                self.catList = categories as! [ExpenseCategory]
                self.preferredContentSize = CGSize(width: 300, height: (self.catList.count * Int(self.tableView.rowHeight) + 88))
                self.tableView.reloadData()
                
            }
        })
    }
    
    func addNewCategory() {
        let categoryInput = UIAlertController(title: "Add New Category", message: "Enter the category name, this will be saved for all users to access", preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add", style: .default) { (_) in
            if let textField = categoryInput.textFields?.first {
                let category = ExpenseCategory()
                category.name = textField.text!
                category.saveInBackground(block: { (success, error) in
                    if error == nil {
                        self.getCategories()
                    }
                })
                
            } else {
                
            }
        }
        
        categoryInput.addTextField { (textField) in
            textField.placeholder = "name"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        categoryInput.addAction(add)
        categoryInput.addAction(cancel)
        self.present(categoryInput, animated: true, completion: nil)
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
        return self.catList.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "addCategory", for: indexPath)
        }
        
        if indexPath.row > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "categoryNameCell", for: indexPath)
            cell.textLabel?.text! = self.catList[indexPath.row - 1].name
            self.preferredContentSize = CGSize(width: 300, height: tableView.contentSize.height + 50)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            addNewCategory()
        }
        
        if indexPath.row > 0 {
            let categoryToSend = self.catList[indexPath.row - 1]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateCategoryName"), object: categoryToSend)
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
