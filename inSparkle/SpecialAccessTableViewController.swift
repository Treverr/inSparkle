//
//  SpecialAccessTableViewController.swift
//  inSparkle
//
//  Created by Trever on 2/27/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class SpecialAccessTableViewController: UITableViewController {
    
    var specAccess = [SpecialAccessObj]()
    var employeeSpecialAccess = [String]()
    
    var userObj : PFUser!
    
    override func viewWillAppear(animated: Bool) {
        if userObj.objectForKey("specialAccess") != nil {
            employeeSpecialAccess = userObj.objectForKey("specialAccess") as! [String]
        }
        getSpecialAccessList()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specAccess.count
    }
    
    func getSpecialAccessList() {
        let query = SpecialAccessObj.query()
        query?.findObjectsInBackgroundWithBlock({ (accesses : [PFObject]?, error : NSError?) in
            if error == nil {
                for access in accesses! {
                    self.specAccess.append(access as! SpecialAccessObj)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("saCell")! as UITableViewCell
        
        let accessName = specAccess[indexPath.row].accessName 
        
        cell.textLabel?.text = accessName
        if employeeSpecialAccess.indexOf(specAccess[indexPath.row].accessName) != nil {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        print(cell.accessoryType.rawValue)
        let access = specAccess[indexPath.row]
        
        if cell.accessoryType == .Checkmark {
            cell.accessoryType = .None
            let indexOf = employeeSpecialAccess.indexOf(access.accessName)
            employeeSpecialAccess.removeAtIndex(indexOf!)
            print(employeeSpecialAccess)
            
        } else if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = .Checkmark
            employeeSpecialAccess.append(access.accessName)
            print(employeeSpecialAccess)
        }
        
    }

    @IBAction func saveButton(sender: AnyObject) {
        let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .Alert)
        self.presentViewController(provAlert, animated: true, completion: nil)
        CloudCode.UpdateUserSpecialAccess(self.userObj.objectId!, specialAccesses: self.employeeSpecialAccess) { (isComplete) in
            if isComplete {
                provAlert.dismissViewControllerAnimated(true, completion: { 
                    self.performSegueWithIdentifier("returnFromAM", sender: self)
                })
                
            }
        }
    }
}
