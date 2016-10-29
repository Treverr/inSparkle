//
//  WorkOrderStatusTableViewController.swift
//  
//
//  Created by Trever on 2/24/16.
//
//

import UIKit

class WorkOrderStatusTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let selectedStatus = cell?.textLabel?.text!
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateStatusLabel"), object: selectedStatus)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
