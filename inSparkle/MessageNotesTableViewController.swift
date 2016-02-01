//
//  MessageNotesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 1/26/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class MessageNotesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notesCell") as! MessageNotesTableViewCell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.tableView.respondsToSelector("setSeparatorInset:") {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        if self.tableView.respondsToSelector("setLayoutMargins:") {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    @IBAction func addNoteAction(sender: AnyObject) {
        
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditNote")
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.contentViewControllerTransitionStyle = .SlideAndBounceFromRight
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNotePopoverSegue" {
            let presentationSegue = segue as! MZFormSheetPresentationViewControllerSegue
            let viewController = presentationSegue.formSheetPresentationController.contentViewController! as UIViewController
            
        }
    }
}
