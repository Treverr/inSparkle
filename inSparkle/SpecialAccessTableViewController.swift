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
    
    override func viewWillAppear(_ animated: Bool) {
        if userObj.object(forKey: "specialAccess") != nil {
            employeeSpecialAccess = userObj.object(forKey: "specialAccess") as! [String]
        }
        getSpecialAccessList()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specAccess.count
    }
    
    func getSpecialAccessList() {
        let query = SpecialAccessObj.query()
        query?.findObjectsInBackground(block: { (accesses : [PFObject]?, error : Error?) in
            if error == nil {
                for access in accesses! {
                    self.specAccess.append(access as! SpecialAccessObj)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saCell")! as UITableViewCell
        
        let accessName = specAccess[(indexPath as NSIndexPath).row].accessName 
        
        cell.textLabel?.text = accessName
        if employeeSpecialAccess.index(of: specAccess[(indexPath as NSIndexPath).row].accessName) != nil {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        print(cell.accessoryType.rawValue)
        let access = specAccess[(indexPath as NSIndexPath).row]
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            let indexOf = employeeSpecialAccess.index(of: access.accessName)
            employeeSpecialAccess.remove(at: indexOf!)
            print(employeeSpecialAccess)
            
        } else if cell.accessoryType == UITableViewCellAccessoryType.none {
            cell.accessoryType = .checkmark
            employeeSpecialAccess.append(access.accessName)
            print(employeeSpecialAccess)
        }
        
    }

    @IBAction func saveButton(_ sender: AnyObject) {
        let provAlert = UIAlertController(title: "Provisioning...", message: nil, preferredStyle: .alert)
        self.present(provAlert, animated: true, completion: nil)
        CloudCode.UpdateUserSpecialAccess(self.userObj.objectId!, specialAccesses: self.employeeSpecialAccess as NSArray) { (isComplete) in
            if isComplete {
                provAlert.dismiss(animated: true, completion: { 
                    self.performSegue(withIdentifier: "returnFromAM", sender: self)
                })
                
            }
        }
    }
}
