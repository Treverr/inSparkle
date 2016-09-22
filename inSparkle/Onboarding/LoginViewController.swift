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
    
    var qrUsername : String?
    var qrPassword : String?
    
    var kbHeight: CGFloat?
    var showUIKeyboard : Bool?
    
    var hasKeyboard = false
    
    @IBOutlet weak var loginButton: UIButton!
    var loadingUI : NVActivityIndicatorView!
    var loadingBackground = UIView()
    var label = UILabel()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var isKeyboardShowing : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("lastUsername") != nil {
            let lastUser = NSUserDefaults.standardUserDefaults().valueForKey("lastUsername") as! String
            usernameField.text = lastUser.lowercaseString
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if UIDevice.currentDevice().name == "Time Clock" {
            let sb = UIStoryboard(name: "TimeClock", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("punch")
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if QRLogInData.username != nil && QRLogInData.password != nil {
                self.usernameField.text = QRLogInData.username
                self.passwordField.text = QRLogInData.password
                QRLogInData.username = nil
                QRLogInData.password = nil
                self.loginAction(self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == usernameField {
            passwordField.becomeFirstResponder()
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
        label.text = "Authenticating with SparkleConnect...."
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
        let username = self.usernameField.text?.lowercaseString
        let password = self.passwordField.text
        
        if usernameField.isFirstResponder() {
            usernameField.resignFirstResponder()
        }
        
        if passwordField.isFirstResponder() {
            passwordField.resignFirstResponder()
        }
        
        if username?.characters.count < 1 {
            // Alert
        } else if password?.characters.count < 1 {
            // Alert
        } else {
            NSUserDefaults.standardUserDefaults().setValue(username!, forKey: "lastUsername")
            let spinner : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
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
    
    @IBAction func qrButton(sender: AnyObject) {
        
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        let scanVC = storyBoard.instantiateViewControllerWithIdentifier("QRCodeScanner")
        
        self.presentViewController(scanVC, animated: true, completion: nil)
        
    }
    
    var isShowing : Bool = false
    
    func keyboardWillShow(notification: NSNotification) {
        
        if usernameField.isFirstResponder() {
            
        }
        
        self.isShowing = true
        
        let info = notification.userInfo
        let keyboardFrame = info![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboard = self.view.convertRect(keyboardFrame!, fromView: self.view.window)
        let height = self.view.frame.size.height
        let toolbarHeight = height - keyboard.origin.y
        
        if ((keyboard.origin.y + keyboard.size.height) > height) {
            self.hasKeyboard = true
        }
        
        if hasKeyboard {
            let contentInset = UIEdgeInsetsMake(0, 0, toolbarHeight, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            self.performSelector(#selector(LoginViewController.scrollToPasswordRect), withObject: nil, afterDelay: 0.1)
        } else {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboard.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            self.performSelector(#selector(LoginViewController.scrollToPasswordRect), withObject: nil, afterDelay: 0.1)
        }
    }
    
    func scrollToPasswordRect() {
        self.scrollView.scrollRectToVisible(self.passwordField.frame, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.isShowing = false
        let contentinset = UIEdgeInsetsZero
        scrollView.contentInset = contentinset
        scrollView.scrollIndicatorInsets = contentinset
    }
    
}
