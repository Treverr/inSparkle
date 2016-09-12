//
//  AddEditMessageNoteViewController.swift
//  inSparkle
//
//  Created by Trever on 2/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class AddEditMessageNoteViewController: UIViewController {
    
    var linkingMessage : Messages?
    var isNewNote = true
    var existingNote : MessageNotes?
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    let deviceType = UIDevice.currentDevice().model

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.origHeight = self.view.frame.size.height
        
        print("Is New Note: \(isNewNote)")
        existingNote?.fetchIfNeededInBackground()
        print(linkingMessage)
        print(existingNote)
        
        if existingNote != nil {
            noteTextView.text = existingNote?.note
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddEditMessageNoteViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(self.keyboardDidHide()), name: UIKeyboardWillHideNotification, object: nil)


    }
    
    var origHeight : CGFloat!
    
    func keyboardWillShow(notification : NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrameScreenValue = userInfo[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameScreen = keyboardFrameScreenValue!.CGRectValue()
        let keyboardFrame = self.view.convertRect(keyboardFrameScreen, fromView: nil)
        let keyboardSize = keyboardFrame.size
        
        
        let covered = self.view.heightCoveredByKeyboardOfSize(keyboardSize)
        self.view.frame.size.height = ((self.view.frame.size.height) - covered)
        self.view.autoresizesSubviews = true
    }
    
    func keyboardDidHide() {
        self.view.frame.size.height = origHeight
        self.view.autoresizesSubviews = true
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        saveButton.enabled = false
        saveButton.tintColor = UIColor.grayColor()
        if isNewNote {
            let newNote = MessageNotes()
            if linkingMessage != nil {
                newNote.pointerMessage = linkingMessage!
            }
            newNote.note = noteTextView.text
            newNote.createdBy = PFUser.currentUser()?.objectForKey("employee") as! Employee
            newNote.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) in
                if (success) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessageNotesTableView", object: nil)
                }
            })
        } else {
            existingNote?.note = noteTextView.text
            existingNote?.saveInBackgroundWithBlock({ (updated : Bool, error : NSError?) in
                if (updated) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("RefreshMessageNotesTableView", object: nil)
                }
            })
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        let alert = UIAlertController(title: "Are you Sure?", message: "Any unsaved changes will be lost, are you sure you want to cancel?", preferredStyle: .Alert)
        
        let yesButton = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let noButton = UIAlertAction(title: "No", style: .Default) { (action) in
            
        }
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.presentViewController(alert, animated: true , completion: nil)
    }
}

extension UIView {
    func heightCoveredByKeyboardOfSize(keyboardSize: CGSize) -> CGFloat {
        let frameInWindow = convertRect(bounds, toView: nil)
        let windowBounds = window?.bounds
        
        if windowBounds == nil { return 0 }
        
        let keyboardTop = windowBounds!.size.height - keyboardSize.height
        let viewBottom = frameInWindow.origin.y + frameInWindow.size.height
        
        return max(0, viewBottom - keyboardTop) + 5
    }
}
