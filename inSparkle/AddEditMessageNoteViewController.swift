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
    let deviceType = UIDevice.current.model

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddEditMessageNoteViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


    }
    
    var origHeight : CGFloat!
    
    func keyboardWillShow(_ notification : Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardFrameScreenValue = userInfo[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameScreen = (keyboardFrameScreenValue! as AnyObject).cgRectValue
        let keyboardFrame = self.view.convert(keyboardFrameScreen!, from: nil)
        let keyboardSize = keyboardFrame.size
        
        
        let covered = self.view.heightCoveredByKeyboardOfSize(keyboardSize)
        self.view.frame.size.height = ((self.view.frame.size.height) - covered)
        self.view.autoresizesSubviews = true
    }
    
    func keyboardDidHide() {
        self.view.frame.size.height = origHeight
        self.view.autoresizesSubviews = true
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.gray
        if isNewNote {
            let newNote = MessageNotes()
            if linkingMessage != nil {
                newNote.pointerMessage = linkingMessage!
            }
            newNote.note = noteTextView.text
            newNote.createdBy = PFUser.current()?.object(forKey: "employee") as! Employee
            newNote.saveInBackground(block: { (success : Bool, error : Error?) in
                if (success) {
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshMessageNotesTableView"), object: nil)
                }
            })
        } else {
            existingNote?.note = noteTextView.text
            existingNote?.saveInBackground(block: { (updated : Bool, error : Error?) in
                if (updated) {
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "RefreshMessageNotesTableView"), object: nil)
                }
            })
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Are you Sure?", message: "Any unsaved changes will be lost, are you sure you want to cancel?", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let noButton = UIAlertAction(title: "No", style: .default) { (action) in
            
        }
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        self.present(alert, animated: true , completion: nil)
    }
}

extension UIView {
    func heightCoveredByKeyboardOfSize(_ keyboardSize: CGSize) -> CGFloat {
        let frameInWindow = convert(bounds, to: nil)
        let windowBounds = window?.bounds
        
        if windowBounds == nil { return 0 }
        
        let keyboardTop = windowBounds!.size.height - keyboardSize.height
        let viewBottom = frameInWindow.origin.y + frameInWindow.size.height
        
        return max(0, viewBottom - keyboardTop) + 5
    }
}
