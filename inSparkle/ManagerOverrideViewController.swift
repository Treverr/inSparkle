//
//  ManagerOverrideViewController.swift
//  inSparkle
//
//  Created by Trever on 11/28/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import NVActivityIndicatorView

class ManagerOverrideViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var overrideReason: UILabel!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var approveButton: UIBarButtonItem!
    
    open var overrideAccessRequired : String!
    open var notifyName : Notification.Name!
    open var overrideReasonLog : String!
    
    @IBOutlet weak var qrCode: UIImageView!
    
    var client : Client! = ParseLiveQuery.Client.shared
    var approvalSub : PFQuery<PFObject>!
    var subscription : Subscription<RemoteApproveRequest>!
    
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
        if self.liveQuery != nil {
            client.unsubscribe(self.liveQuery as! PFQuery<PFObject>)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var raLabel : UILabel!
    var raWaiting : NVActivityIndicatorView!
    
    @IBAction func remoteApprove(_ sender: Any) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let waiting = NVActivityIndicatorView(frame: frame, type: .ballClipRotate, color: UIColor.white, padding: 3)
        
        let background = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        background.layer.opacity = 0.75
        background.center = self.view.center
        background.layer.cornerRadius = 5
        background.backgroundColor = UIColor.black
        
        waiting.center = CGPoint(x: background.center.x, y: background.center.y - 15)
        waiting.color = UIColor.white
        self.raWaiting = waiting
        
        let label = UILabel(frame: background.frame)
        label.text = "Waiting for approval..."
        label.textColor = UIColor.white
        label.center = CGPoint(x: background.center.x, y: background.center.y + 105)
        label.textAlignment = .center
        self.raLabel = label
        
        
        self.view.addSubview(background)
        self.view.addSubview(label)
        self.view.addSubview(waiting)
        
        waiting.startAnimating()
        
        let remoteApproval = RemoteApproveRequest()
        remoteApproval.requestReason = self.overrideReason.text?.components(separatedBy: "inSparkle requires you to find a manager to override ").last?.capitalized
        remoteApproval.requestedBy = EmployeeData.universalEmployee
        remoteApproval.overrideType = "POC"
        remoteApproval.saveInBackground { (success, error) in
            if error == nil {
                let params = [
                    "requestid" : remoteApproval.objectId!,
                    "fromperson" : remoteApproval.requestedBy.firstName.capitalized
                ]
                PFCloud.callFunction(inBackground: "RemoteApprovalPN", withParameters: params)
                self.subscribeLiveQuery(object: remoteApproval)
            }
        }
        
        print(remoteApproval)
        
    }
    
    var liveQuery : PFQuery<RemoteApproveRequest>!
    
    func subscribeLiveQuery(object : RemoteApproveRequest) {
        print(object)
        
        var liveQuery : PFQuery<RemoteApproveRequest> {
            return(RemoteApproveRequest.query()?
                .whereKeyExists("respondedBy")
                .whereKeyExists("response")
                .includeKey("respondedBy")
                .whereKey("objectId", equalTo: object.objectId!) as! PFQuery<RemoteApproveRequest>
            )
        }
        self.liveQuery = liveQuery
        
        self.subscription = client.subscribe(liveQuery)
        
        subscription
        .handle(Event.entered) { _, object in
            self.handleRemoteApproved(object: object)
        }
    }
    
    func handleRemoteApproved(object : RemoteApproveRequest) {
        let remoteQuery = RemoteApproveRequest.query()
        remoteQuery?.includeKey("respondedBy")
        remoteQuery?.whereKey("objectId", equalTo: object.objectId!)
        remoteQuery?.getFirstObjectInBackground(block: { (remoteObject : PFObject?, error) in
            if error == nil {
                let employee = remoteObject?.object(forKey: "respondedBy") as! Employee
                DispatchQueue.main.async {
                    self.raWaiting.stopAnimating()
                    self.raWaiting.removeFromSuperview()
                    
                    if object.response!.contains("Approved") {
                        let approvedImageView = UIImageView(frame: self.raWaiting.frame)
                        approvedImageView.image = UIImage(named: "ManagerOverrideRemoteApprovalIcon")
                        approvedImageView.center = self.raWaiting.center
                        self.view.addSubview(approvedImageView)
                    }
                    
                    if object.response!.contains("Denied") {
                        let deniedImageView = UIImageView(frame: self.raWaiting.frame)
                        deniedImageView.image = UIImage(named: "ManagerOverrideRemoteDenialIcon")
                        deniedImageView.center = self.raWaiting.center
                        self.view.addSubview(deniedImageView)
                    }
                    
                    self.raLabel.text = object.response! + " by " + employee.firstName.capitalized
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.client.unsubscribe(self.liveQuery as! PFQuery<PFObject>)
                        self.dismiss(animated: true, completion: {
                        })
                        
                        if object.response!.contains("Approved") {
                            var approve = true
                            NotificationCenter.default.post(name: self.notifyName, object: approve)
                        }
                        
                    }
                }
            } else {
                print(error)
            }
        })
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
    
//    @IBAction func remoteApprove(_ sender: Any) {
//        let alert = UIAlertController(title: "Are you sure?", message: "This will send a notification to all Admin's that can approve this.", preferredStyle: .alert)
//        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { (action) in
//        
//        }
//        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancelButton)
//        alert.addAction(yesButton)
//        self.present(alert, animated: true, completion: nil)
//        
//    }

}
