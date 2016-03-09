//
//  MessageNotesTableViewCell.swift
//  inSparkle
//
//  Created by Trever on 1/26/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit

class MessageNotesTableViewCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var notes: UITextView!
    @IBOutlet var enteredBy: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notes.scrollEnabled = false
        notes.delegate = self
        
    }
    
    var textString : String {
        get {
            return notes.text
        }
        set {
            notes.text = newValue
            
            textViewDidChange(notes)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            notes.becomeFirstResponder()
        } else {
            notes.resignFirstResponder()
        }
        
    }
}

extension MessageNotesTableViewCell : UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableView?.indexPathForCell(self) {
                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}
