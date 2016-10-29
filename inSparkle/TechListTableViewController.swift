//
//  TechListTableViewController.swift
//  inSparkle
//
//  Created by Trever on 9/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class TechListTableViewController: UITableViewController {
    
    var techs : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize.height = CGFloat(self.techs.count * 44)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.techs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "techCell")
        
        cell?.textLabel?.text = self.techs[(indexPath as NSIndexPath).row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let techName = cell?.textLabel?.text!
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTechLabel"), object: techName!)
        self.dismiss(animated: true, completion: nil)
    }

}
