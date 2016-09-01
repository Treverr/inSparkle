//
//  MessageNotesTableViewController.swift
//  inSparkle
//
//  Created by Trever on 1/26/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import Parse

class MessageNotesTableViewController: UITableViewController {
    
    var linkingMessage : Messages?
    
    var messageNotes = [MessageNotes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewExtraCells()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageNotesTableViewController.refresh), name: "RefreshMessageNotesTableView", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getMessageNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageNotes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notesCell") as! MessageNotesTableViewCell
        cell.notes.userInteractionEnabled = false
        let noteObject = messageNotes[indexPath.row] 
        let note = noteObject.note
        let time = noteObject.createdAt!
        if noteObject.createdBy != nil {
            _ = noteObject.createdBy!
            noteObject.createdBy?.fetchInBackgroundWithBlock({ (employee : PFObject?, error : NSError?) in
                if error == nil {
                    let emp = employee as! Employee
                    cell.enteredBy.text = "Entered By: " + emp.firstName.capitalizedString
                }
            })
            
        } else {
            cell.enteredBy.text! = ""
        }
        
        print(messageNotes[indexPath.row])
        
        let noteTimeDateFormatter = NSDateFormatter()
        noteTimeDateFormatter.timeStyle = .ShortStyle
        noteTimeDateFormatter.dateStyle = .ShortStyle
        noteTimeDateFormatter.doesRelativeDateFormatting = true
        
        let timeString = noteTimeDateFormatter.stringFromDate(time)
        
        cell.notes.text = note
        cell.title.text = timeString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func refresh() {
        messageNotes.removeAll()
        getMessageNotes()
    }
    
    @IBAction func addNoteAction(sender: AnyObject) {
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditNote") as! AddEditMessageNoteViewController
        if linkingMessage != nil {
            viewController.linkingMessage = self.linkingMessage!
        }
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.contentViewControllerTransitionStyle = .SlideAndBounceFromRight
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 500)
        
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedNote = messageNotes[indexPath.row]
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddEditNote")as! AddEditMessageNoteViewController
        viewController.isNewNote = false
        viewController.existingNote = selectedNote
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.contentViewControllerTransitionStyle = .SlideAndBounceFromRight
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 500)
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(formSheetController, animated: true, completion: nil)
        
    }
    
    func tableViewExtraCells() {
        let tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.whiteColor()
    }
    
    func getMessageNotes() {
        if linkingMessage != nil {
            let query = MessageNotes.query()
            query?.whereKey("pointerMessage", equalTo: linkingMessage!)
            query?.addAscendingOrder("createdAt")
            query?.findObjectsInBackgroundWithBlock({ (notes : [PFObject]?, error : NSError?) in
                if error == nil {
                    for note in notes! {
                        let theNote = note as! MessageNotes
                        self.messageNotes.append(theNote)
                        self.tableView.reloadData()
                    }
                }
            })
            
        }
    }
    
}
