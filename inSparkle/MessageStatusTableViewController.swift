//
//  MessageStatusTableViewController.swift
//  
//
//  Created by Trever on 1/26/16.
//
//

import UIKit

class MessageStatusTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var selectedStatus : String!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        selectedStatus = cell?.textLabel?.text!
        print(selectedStatus)
        self.performSegue(withIdentifier: "updateStatusLabel", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateStatusLabel" {
            let dest = segue.destination as! ComposeMessageTableViewController
            dest.statusLabel.text = "Status: " + selectedStatus
            
        }
    }

}
