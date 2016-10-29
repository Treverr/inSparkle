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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessageNotesTableViewController.refresh), name: NSNotification.Name(rawValue: "RefreshMessageNotesTableView"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMessageNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageNotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! MessageNotesTableViewCell
        cell.notes.isUserInteractionEnabled = false
        let noteObject = messageNotes[(indexPath as NSIndexPath).row] 
        let note = noteObject.note
        let time = noteObject.createdAt!
        if noteObject.createdBy != nil {
            _ = noteObject.createdBy!
            noteObject.createdBy?.fetchInBackground(block: { (employee : PFObject?, error : Error?) in
                if error == nil {
                    let emp = employee as! Employee
                    cell.enteredBy.text = "Entered By: " + emp.firstName.capitalized
                }
            })
            
        } else {
            cell.enteredBy.text! = ""
        }
        
        print(messageNotes[(indexPath as NSIndexPath).row])
        
        let noteTimeDateFormatter = DateFormatter()
        noteTimeDateFormatter.timeStyle = .short
        noteTimeDateFormatter.dateStyle = .short
        noteTimeDateFormatter.doesRelativeDateFormatting = true
        
        let timeString = noteTimeDateFormatter.string(from: time)
        
        cell.notes.text = note
        cell.title.text = timeString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            self.tableView.separatorInset = UIEdgeInsets.zero
        }
        if self.tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            self.tableView.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func refresh() {
        messageNotes.removeAll()
        getMessageNotes()
    }
    
    @IBAction func addNoteAction(_ sender: AnyObject) {
        
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddEditNote") as! AddEditMessageNoteViewController
        if linkingMessage != nil {
            viewController.linkingMessage = self.linkingMessage!
        }
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.contentViewControllerTransitionStyle = .slideAndBounceFromRight
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 500)
        
        
        self.present(formSheetController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = messageNotes[(indexPath as NSIndexPath).row]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddEditNote")as! AddEditMessageNoteViewController
        viewController.isNewNote = false
        viewController.existingNote = selectedNote
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.contentViewControllerTransitionStyle = .slideAndBounceFromRight
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 500)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.present(formSheetController, animated: true, completion: nil)
        
    }
    
    func tableViewExtraCells() {
        let tblView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.isHidden = true
        tableView.backgroundColor = UIColor.white
    }
    
    func getMessageNotes() {
        if linkingMessage != nil {
            let query = MessageNotes.query()
            query?.whereKey("pointerMessage", equalTo: linkingMessage!)
            query?.addAscendingOrder("createdAt")
            query?.findObjectsInBackground(block: { (notes : [PFObject]?, error : Error?) in
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
