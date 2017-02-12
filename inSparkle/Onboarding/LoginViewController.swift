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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
        
        if UserDefaults.standard.object(forKey: "lastUsername") != nil {
            let lastUser = UserDefaults.standard.value(forKey: "lastUsername") as! String
            usernameField.text = lastUser.lowercased()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UIDevice.current.name == "Time Clock" {
            let sb = UIStoryboard(name: "TimeClock", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "punch")
            self.present(vc, animated: true, completion: nil)
        }
        
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }
        
        if  !usernameField.text!.isEmpty && !passwordField.text!.isEmpty {
            loginAction(self)
        }
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func sparkleConnectAnimation() {
        
        let x = (self.view.frame.size.width / 2)
        let y = (self.view.frame.size.height / 2)
        
        self.loadingBackground.backgroundColor = UIColor.black
        self.loadingBackground.frame = CGRect(x: 0, y: 0, width: 300, height: 125)
        self.loadingBackground.center = self.view.center
        self.loadingBackground.layer.cornerRadius = 5
        self.loadingBackground.layer.opacity = 0.75
        
        self.loadingUI = NVActivityIndicatorView(frame: CGRect(x: x, y: y, width: 100, height: 50))
        self.loadingUI.center = self.loadingBackground.center
        
        label.frame = loadingBackground.frame
        label.center = CGPoint(x: self.loadingBackground.center.x, y: self.loadingBackground.center.y + 35)
        label.text = "Authenticating with SparkleConnect...."
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        self.view.addSubview(loadingBackground)
        self.view.addSubview(loadingUI)
        self.view.addSubview(label)
        
        loadingUI.type = .ballBeat
        loadingUI.color = UIColor.white
        loadingUI.startAnimating()
        
    }
    
    @IBAction func loginAction(_ sender : AnyObject) {
        let username = self.usernameField.text?.lowercased()
        let password = self.passwordField.text
        
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        }
        
        if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }
        
        if username?.characters.count < 1 {
            // Alert
        } else if password?.characters.count < 1 {
            // Alert
        } else {
            UserDefaults.standard.setValue(username!, forKey: "lastUsername")
            let spinner : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            sparkleConnectAnimation()
            
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (user, error) -> Void in
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    
                    if (user!.object(forKey: "isActive") as! Bool == true ) {
                        
                        self.closeLogin()
                        
                        do {
                            try PFUser.current()?.fetch()
                            print(PFUser.current())
                            if PFUser.current() != nil {
                                let employee = PFUser.current()?.object(forKey: "employee") as? Employee
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
                        let notActive = Banner(title: "Your account has been disabled, please see your manager.", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
                        notActive.dismissesOnTap = true
                        notActive.show(duration: 5.0)
                        
                        self.loadingUI.stopAnimating()
                        self.loadingBackground.removeFromSuperview()
                        self.label.removeFromSuperview()
                        
                    }
                    
                    
                    
                } else {
                    print(error)
                    let banner = Banner(title: "Incorrect username or password", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 5.0)
                    
                    self.loadingUI.stopAnimating()
                    self.loadingBackground.removeFromSuperview()
                    self.label.removeFromSuperview()
                }
            })
        }
    }
    
    func closeLogin() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.label.text = "Loading user information..."
            self.loadingUI.stopAnimating()
            self.loadingBackground.removeFromSuperview()
            self.label.removeFromSuperview()
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @IBAction func qrButton(_ sender: AnyObject) {
        
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        let scanVC = storyBoard.instantiateViewController(withIdentifier: "QRCodeScanner")
        
        self.present(scanVC, animated: true, completion: nil)
        
    }
    
    var isShowing : Bool = false
    
    func keyboardWillShow(_ notification: Notification) {
        
        if usernameField.isFirstResponder {
            
        }
        
        self.isShowing = true
        
        let info = (notification as NSNotification).userInfo
        let keyboardFrame = (info![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboard = self.view.convert(keyboardFrame!, from: self.view.window)
        let height = self.view.frame.size.height
        let toolbarHeight = height - keyboard.origin.y
        
        if ((keyboard.origin.y + keyboard.size.height) > height) {
            self.hasKeyboard = true
        }
        
        if hasKeyboard {
            let contentInset = UIEdgeInsetsMake(0, 0, toolbarHeight, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            self.perform(#selector(LoginViewController.scrollToPasswordRect), with: nil, afterDelay: 0.1)
        } else {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboard.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            self.perform(#selector(LoginViewController.scrollToPasswordRect), with: nil, afterDelay: 0.1)
        }
    }
    
    func scrollToPasswordRect() {
        self.scrollView.scrollRectToVisible(self.passwordField.frame, animated: true)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.isShowing = false
        let contentinset = UIEdgeInsets.zero
        scrollView.contentInset = contentinset
        scrollView.scrollIndicatorInsets = contentinset
    }
    
}
