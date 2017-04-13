//
//  ManagerOverrideViewController.swift
//  inSparkle
//
//  Created by Trever on 11/28/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse

class ManagerOverrideViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var overrideReason: UILabel!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var approveButton: UIBarButtonItem!
    
    open var overrideAccessRequired : String!
    open var notifyName : Notification.Name!
    
    @IBOutlet weak var qrCode: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
//        blurImageView.image = ManagerOverride.image
        
//        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
//        // 2
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = self.view.frame
//        // 3
//        blurImageView.addSubview(blurView)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        if QRLogInData.username != nil && QRLogInData.password != nil {
            self.username.text = QRLogInData.username
            self.password.text = QRLogInData.password
            QRLogInData.username = nil
            QRLogInData.password = nil
            self.approveAction(approveButton)
        }
    }
    
    @IBAction func qrButton(_ sender: AnyObject) {
        
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        let scanVC = storyBoard.instantiateViewController(withIdentifier: "QRCodeScanner")
        
        self.present(scanVC, animated: true, completion: nil)
        
    }
    
    @IBAction func closeCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func approveAction(_ sender: Any) {
        
        let params = [
            "username" : self.username.text?.lowercased(),
            "password" : self.password.text!
        ]
        
        PFCloud.callFunction(inBackground: "managerOverride", withParameters: params) { (returnUser, returnError) in
            var approve : Bool = false
            
            if returnError == nil {
                let theUser = returnUser as! PFUser
                
                if (theUser.object(forKey: "isAdmin") as! Bool) {
                    approve = true
                    self.dismiss(animated: true, completion: {
                    })
                    NotificationCenter.default.post(name: self.notifyName, object: approve)
                } else {
                    self.errorAlert(message: "User [\(self.username.text!.lowercased())] does not have privilages to perform override, please try again.")
                }
                
            } else {
                let errorCode = returnError as! NSError
                
                switch errorCode.code {
                case 141:
                    self.errorAlert(message: "Invalid User Name or Password")
                default:
                    break
                }
            }
        }
        
    }
    
    func errorAlert(message : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func remoteApprove(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will send a notification to all Admin's that can approve this.", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { (action) in
        
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(yesButton)
        self.present(alert, animated: true, completion: nil)
        
    }

}
