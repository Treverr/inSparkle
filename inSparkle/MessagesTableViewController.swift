//
//  MessagesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 12/23/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class MessagesTableViewController: UITableViewController {
    
    var theMesages = [Messages]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationbar()
        getEmpMessagesFromParse()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return theMesages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesMainTableViewCell
        if theMesages.count > 0 {
            let name = theMesages[indexPath.row].messageFromName
            let date = theMesages[indexPath.row].dateEntered
            let status = theMesages[indexPath.row].status
            var statusTime = theMesages[indexPath.row].statusTime
            let unread = theMesages[indexPath.row].unread
            
            cell.configureCell(name, date: date, messageStatus: status, statusTime: statusTime, unread: unread)
        }
        
        return cell
        
    }
    
    func setupNavigationbar()  {
        self.navigationController?.navigationBar.barTintColor = Colors.sparkleBlue
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    func getEmpMessagesFromParse() {
        let query = Messages.query()
        let employeeObj = PFUser.currentUser()?.objectForKey("employee") as! Employee
        employeeObj.fetchIfNeededInBackground()
        query?.whereKey("recipient", equalTo: employeeObj)
        query?.findObjectsInBackgroundWithBlock({ (messages : [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for msg in messages! {
                    self.theMesages.append(msg as! Messages)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    
    @IBAction func unwindToMessageList(segue : UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ViewEditMessage" {
            let dest = segue.destinationViewController as! ComposeMessageTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let selectMessage = theMesages[indexPath!.row] as! Messages
            dest.isNewMessage = false
            dest.existingMessage = selectMessage
        }
        
    }


}
