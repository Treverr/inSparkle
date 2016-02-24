//
//  WorkOrdersTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class WorkOrdersTableViewController: UITableViewController {
    
    var theWorkOrders = [WorkOrders]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar() 
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getWorkOrders()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return theWorkOrders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("workOrder") as! WorkOrdersMainTableViewCell
        
        let customerName = theWorkOrders[indexPath.row].customerName
        let dateCreated = theWorkOrders[indexPath.row].date
        let theStatus = theWorkOrders[indexPath.row].status
        
        cell.configureCell(customerName, dateCreated: dateCreated, status: theStatus)
        
        return cell
    }
    
    func getWorkOrders() {
        self.theWorkOrders.removeAll()
        
        let query = WorkOrders.query()
        query?.findObjectsInBackgroundWithBlock({ (workOrders : [PFObject]?, error :NSError?) in
            if error == nil {
                for order in workOrders! {
                    self.theWorkOrders.append(order as! WorkOrders)
                }
                self.tableView.reloadData()
            }
        })
        
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }

}
