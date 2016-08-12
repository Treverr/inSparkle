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
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var kbHeight: CGFloat?
    var showUIKeyboard : Bool?
    
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    var label = UILabel()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    var isKeyboardShowing : Bool?
    
    override func viewDidLoad() {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("lastUsername") != nil {
            let lastUser = NSUserDefaults.standardUserDefaults().valueForKey("lastUsername") as! String
            usernameField.text = lastUser.lowercaseString
        }
        
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        //
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        
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
    
    func sparkleConnectAnimation() {
        
        let x = (self.view.frame.size.width / 2)
        let y = (self.view.frame.size.height / 2)
        
        self.loadingBackground.backgroundColor = UIColor.blackColor()
        self.loadingBackground.frame = CGRectMake(0, 0, 300, 125)
        self.loadingBackground.center = self.view.center
        self.loadingBackground.layer.cornerRadius = 5
        self.loadingBackground.layer.opacity = 0.75
        
        self.loadingUI = NVActivityIndicatorView(frame: CGRectMake(x, y, 100, 50))
        self.loadingUI.center = self.loadingBackground.center
        
        label.frame = loadingBackground.frame
        label.center = CGPointMake(self.loadingBackground.center.x, self.loadingBackground.center.y + 35)
        label.text = "Authenticaing with SparkleConnect...."
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        
        self.view.addSubview(loadingBackground)
        self.view.addSubview(loadingUI)
        self.view.addSubview(label)
        
        loadingUI.type = .BallBeat
        loadingUI.color = UIColor.whiteColor()
        loadingUI.startAnimation()
        
    }
    
    @IBAction func loginAction(sender : AnyObject) {
        var username = self.usernameField.text?.lowercaseString
        var password = self.passwordField.text
        
        if username?.characters.count < 1 {
            // Alert
        } else if password?.characters.count < 1 {
            // Alert
        } else {
            NSUserDefaults.standardUserDefaults().setValue(username!, forKey: "lastUsername")
            var spinner : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            sparkleConnectAnimation()
        
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                    spinner.stopAnimating()
                    
                    if ((user) != nil) {
                        
                        if (user!.objectForKey("isActive") as! Bool == true ) {
                            
                            self.closeLogin()
                            
                            do {
                                try PFUser.currentUser()?.fetch()
                                print(PFUser.currentUser())
                                if PFUser.currentUser() != nil {
                                    let employee = PFUser.currentUser()?.objectForKey("employee") as? Employee
                                    do {
                                        try employee!.fetch()
                                    } catch {
                                    }
                                    
                                    EmployeeData.universalEmployee = employee
                                    
                                }
                            } catch {
                                print("Error")
                            }
                        } else {
                            PFUser.logOut()
                            self.passwordField.text = nil
                            let notActive = Banner(title: "Your account has been disabled, please see your manager.", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
                            notActive.dismissesOnTap = true
                            notActive.show(duration: 5.0)
                            
                            self.loadingUI.stopAnimation()
                            self.loadingBackground.removeFromSuperview()
                            self.label.removeFromSuperview()
                            
                        }
                        
                        
                        
                    } else {
                        let banner = Banner(title: "Incorrect username or password", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
                        banner.dismissesOnTap = true
                        banner.show(duration: 5.0)
                        
                        self.loadingUI.stopAnimation()
                        self.loadingBackground.removeFromSuperview()
                        self.label.removeFromSuperview()
                    }
            })
        }
    }
    
    func closeLogin() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.label.text = "Loading user information..."
            self.loadingUI.stopAnimation()
            self.loadingBackground.removeFromSuperview()
            self.label.removeFromSuperview()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })
    }
    
    func loginWithQR() {
        let qrCode = "2vigcitsl6"
        let session = PFSession()
    }
    
}
