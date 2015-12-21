//
//  LoginViewController.swift
//  inSparkle
//
//  Created by Trever on 11/16/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Parse
import BRYXBanner

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var kbHeight: CGFloat?
    var showUIKeyboard : Bool?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    var isKeyboardShowing : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        if UIDevice.currentDevice().name == "Time Clock" {
            let sb = UIStoryboard(name: "TimeClock", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("punch")
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func keyboardWillShow(notification : NSNotification) {
        
        if isKeyboardShowing == true {
            return
        } else {
            if let userInfo = notification.userInfo {
                if let keyboardSize = (userInfo [UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    kbHeight = keyboardSize.height
                    self.animateTextField(true)
                    isKeyboardShowing = true
                }
            }
        }
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func keyboardWillHide(notification : NSNotification) {
        self.animateTextField(false)
        isKeyboardShowing = false
    }
    
    func animateTextField(up: Bool) {
        if kbHeight == nil {
            return
        } else {
            let movement = (up ? -kbHeight! + 150 : kbHeight! - 150)
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement)
            })
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == usernameField {
            usernameField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }
        
        if textField == passwordField {
            textField.resignFirstResponder()
        }
        
        if  !usernameField.text!.isEmpty && !passwordField.text!.isEmpty {
            loginAction(self)
        }
        
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func loginAction(sender : AnyObject) {
        var username = self.usernameField.text?.lowercaseString
        var password = self.passwordField.text
        
        if username?.characters.count < 1 {
           // Alert
        } else if password?.characters.count < 1 {
            // Alert
        } else {
            var spinner : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    
                    self.closeLogin()
                    
                } else {
                    let banner = Banner(title: "Incorrect username or password", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
                    banner.dismissesOnTap = false
                    banner.show(duration: 10.0)
                }
            })
        }
    }
    
    func closeLogin() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

}
