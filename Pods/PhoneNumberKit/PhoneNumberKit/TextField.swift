//
//  TextField.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 07/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit

/// Custom text field that formats phone numbers
public class PhoneNumberTextField: UITextField, UITextFieldDelegate {
    
    /// Override region to set a custom region. Automatically uses the default region code.
    public var region = PhoneNumberKit().defaultRegionCode() {
        didSet {
            partialFormatter = PartialFormatter(region: region)
        }
    }
    
    var partialFormatter = PartialFormatter()
    
    let nonNumericSet: NSCharacterSet = {
        var mutableSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet.mutableCopy() as! NSMutableCharacterSet
        mutableSet.removeCharactersInString(plusChars)
        return mutableSet
    }()
    
    weak private var _delegate: UITextFieldDelegate?
    
    override public var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }
        set {
            self._delegate = delegate
        }
    }
    
     //MARK: Lifecycle
    
    /**
    Init with frame
    
    - parameter frame: UITextfield F
    
    - returns: UITextfield
    */
    override public init(frame:CGRect)
    {
        super.init(frame:frame)
        self.setup()
    }
    
     /**
     Init with coder
     
     - parameter aDecoder: decoder
     
     - returns: UITextfield
     */
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup(){
        self.autocorrectionType = .No
        self.keyboardType = UIKeyboardType.PhonePad
        super.delegate = self
    }

    
    // MARK: Phone number formatting
    
    /**
    *  To keep the cursor position, we find the character immediately after the cursor and count the number of times it repeats in the remaining string as this will remain constant in every kind of editing.
    */
    
    internal struct CursorPosition {
        let numberAfterCursor: String
        let repetitionCountFromEnd: Int
    }
    
    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard let text = text, let selectedTextRange = selectedTextRange else {
            return nil
        }
        let textAsNSString = text as NSString
        let cursorEnd = offsetFromPosition(beginningOfDocument, toPosition: selectedTextRange.end)
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for var i = cursorEnd; i < textAsNSString.length; i++  {
            let cursorRange = NSMakeRange(i, 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substringWithRange(cursorRange)
            if (candidateNumberAfterCursor.rangeOfCharacterFromSet(nonNumericSet).location == NSNotFound) {
                for var j = cursorRange.location; j < textAsNSString.length; j++  {
                    let candidateCharacter = textAsNSString.substringWithRange(NSMakeRange(j, 1))
                    if candidateCharacter == candidateNumberAfterCursor {
                        repetitionCountFromEnd++
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor as String, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }
    
    // Finds position of previous cursor in new formatted text
    internal func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        let textAsNSString = formattedText as NSString
        var countFromEnd = 0
        guard let cursorPosition = extractCursorPosition() else {
            return nil
        }
        for var i = (textAsNSString.length - 1); i >= 0; i--  {
            let candidateRange = NSMakeRange(i, 1)
            let candidateCharacter = textAsNSString.substringWithRange(candidateRange)
            if candidateCharacter == cursorPosition.numberAfterCursor {
                countFromEnd++
                if countFromEnd == cursorPosition.repetitionCountFromEnd {
                    return candidateRange
                }
            }
        }
        return nil
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = text else {
            return false
        }
        let textAsNSString = text as NSString
        let changedRange = textAsNSString.substringWithRange(range) as NSString
        let modifiedTextField = textAsNSString.stringByReplacingCharactersInRange(range, withString: string)
        let formattedNationalNumber = partialFormatter.formatPartial(modifiedTextField as String)
        var selectedTextRange: NSRange?
        
        let nonNumericRange = (changedRange.rangeOfCharacterFromSet(nonNumericSet).location != NSNotFound)
        if (range.length == 1 && string.isEmpty && nonNumericRange)
        {
            selectedTextRange = selectionRangeForNumberReplacement(textField, formattedText: modifiedTextField)
            textField.text = modifiedTextField
        }
        else {
            selectedTextRange = selectionRangeForNumberReplacement(textField, formattedText: formattedNationalNumber)
            textField.text = formattedNationalNumber
        }
        if let selectedTextRange = selectedTextRange, let selectionRangePosition = textField.positionFromPosition(beginningOfDocument, offset: selectedTextRange.location) {
            let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
            textField.selectedTextRange = selectionRange
        }

        return false
    }
    
    //MARK: UITextfield Delegate
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if ((_delegate?.respondsToSelector("textFieldShouldBeginEditing:")) != nil) {
            return _delegate!.textFieldShouldBeginEditing!(textField)
        }
        else {
            return true
        }
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        if ((_delegate?.respondsToSelector("textFieldDidBeginEditing:")) != nil) {
            _delegate!.textFieldDidBeginEditing!(textField)
        }
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if ((_delegate?.respondsToSelector("textFieldShouldEndEditing:")) != nil) {
            return _delegate!.textFieldShouldEndEditing!(textField)
        }
        else {
            return true
        }
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        if ((_delegate?.respondsToSelector("textFieldDidEndEditing:")) != nil) {
            _delegate!.textFieldDidEndEditing!(textField)
        }
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        if ((_delegate?.respondsToSelector("textFieldShouldClear:")) != nil) {
            return _delegate!.textFieldShouldClear!(textField)
        }
        else {
            return true
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if ((_delegate?.respondsToSelector("textFieldShouldReturn:")) != nil) {
            return _delegate!.textFieldShouldReturn!(textField)
        }
        else {
            return true
        }
    }


}