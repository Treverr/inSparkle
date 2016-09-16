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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.techs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("techCell")
        
        cell?.textLabel?.text = self.techs[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let techName = cell?.textLabel?.text!
        NSNotificationCenter.defaultCenter().postNotificationName("updateTechLabel", object: techName!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
