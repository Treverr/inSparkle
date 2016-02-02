//
//  AddEditMessageNoteViewController.swift
//  inSparkle
//
//  Created by Trever on 2/1/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class AddEditMessageNoteViewController: UIViewController {
    
    var linkingMessage : Messages?
    var isNewNote = true
    var existingNote : MessageNotes?
    @IBOutlet var noteTextView: UITextView!
    let deviceType = UIDevice.currentDevice().model

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Is New Note: \(isNewNote)")
        existingNote?.fetchIfNeededInBackground()
        print(linkingMessage)
        print(existingNote)
        
        if existingNote != nil {
            noteTextView.text = existingNote?.note
        }


    }
    
    func keyboardWillShow() {
        if deviceType == "iPhone" {
            let moveUpBy = UIView().heightCoveredByKeyboardOfSize(<#T##keyboardSize: CGSize##CGSize#>)
        }
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if isNewNote {
            let newNote = MessageNotes()
            if linkingMessage != nil {
                newNote.pointerMessage = linkingMessage!
            }
            newNote.note = noteTextView.text
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
        
        return max(0, viewBottom - keyboardTop)
    }
}
