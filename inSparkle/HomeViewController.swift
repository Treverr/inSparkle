//
//  HomeViewController.swift
//  inSparkle
//
//  Created by Trever on 11/20/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import UIKit
import Spring
import Parse

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var helloTextView: UITextView!
    
    @IBOutlet weak var addButton: SpringButton!
    @IBOutlet weak var messageLabel: SpringLabel!
    @IBOutlet weak var pocLabel: SpringLabel!
    @IBOutlet weak var workOrderLabel: SpringLabel!
    @IBOutlet weak var soiLabel: SpringLabel!
    
    @IBOutlet weak var messageButton: SpringButton!
    @IBOutlet weak var pocButton: SpringButton!
    @IBOutlet weak var woButton: SpringButton!
    @IBOutlet weak var soiButton: SpringButton!
    
    @IBOutlet weak var allAddView: SpringView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.current() != nil {
           setUpHello()
        } else {
            
        }

        let messageTap = UITapGestureRecognizer(target: self, action: #selector(self.addLabelTapped(sender:)))
        messageTap.numberOfTapsRequired = 1
        messageTap.delegate = self
        let pocTap = UITapGestureRecognizer(target: self, action: #selector(self.addLabelTapped(sender:)))
        pocTap.numberOfTapsRequired = 1
        pocTap.delegate = self
        let workOrderTap = UITapGestureRecognizer(target: self, action: #selector(self.addLabelTapped(sender:)))
        workOrderTap.numberOfTapsRequired = 1
        workOrderTap.delegate = self
        let soiTap = UITapGestureRecognizer(target: self, action: #selector(self.addLabelTapped(sender:)))
        soiTap.numberOfTapsRequired = 1
        soiTap.delegate = self
        
        messageLabel.addGestureRecognizer(messageTap)
        messageLabel.isUserInteractionEnabled = true
        pocLabel.addGestureRecognizer(pocTap)
        pocLabel.isUserInteractionEnabled = true
        workOrderLabel.addGestureRecognizer(workOrderTap)
        workOrderLabel.isUserInteractionEnabled = true
        soiLabel.addGestureRecognizer(soiTap)
        soiLabel.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            setUpHello()
        } else {
            
        }
    }
    
    func triggerLogIn() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpHello() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            self.helloTextView.text = "Good morning,\n" + EmployeeData.universalEmployee.firstName.capitalized
        }
        
        if hour <= 12 && hour >= 17 {
            self.helloTextView.text = "Good afternoon,\n"  + EmployeeData.universalEmployee.firstName.capitalized
        }
        
        if hour > 17 {
            self.helloTextView.text = "Good evening,\n" + EmployeeData.universalEmployee.firstName.capitalized
        }
        
    }
    
    var addButtonIsRotated = false
    
    @IBAction func addNewMainButton(_ sender: Any) {
        if self.addButtonIsRotated {
            self.allAddView.animation = "fadeOut"
            self.allAddView.duration = 0.5
            self.allAddView.animate()
            UIView.animate(withDuration: 0.5, animations: {
                self.addButton.transform = CGAffineTransform(rotationAngle: 0)
                self.addButtonIsRotated = false
                
            })
        } else {
            self.allAddView.animation = "fadeInUp"
            self.allAddView.duration = 0.5
            self.allAddView.animate()
            UIView.animate(withDuration: 0.5, animations: {
                self.addButton.transform = CGAffineTransform(rotationAngle: (-45 * CGFloat(M_PI)) / 180.0)
                self.addButtonIsRotated = true
                
            })
        }
        
    }
    
    func addLabelTapped(sender : UITapGestureRecognizer) {
        let tag = sender.view!.tag
        
        switch tag {
        case 100:
            presentNewMessage()
        case 101:
            presentNewMessage()
        case 102:
            presentNewMessage()
        case 103:
            presentNewMessage()
        default:
            break
        }
        
    }
    
    func presentNewMessage() {
        self.addNewMainButton(self)
        
        let sb = UIStoryboard(name: "Messages", bundle: nil)
        let nav = UINavigationController()
        let composeView = sb.instantiateViewController(withIdentifier: "composeMessage") as! ComposeMessageTableViewController
        nav.viewControllers = [composeView]
        let vc = UIApplication.shared.keyWindow!.rootViewController!
        nav.modalPresentationStyle = .formSheet
        nav.setupNavigationbar(nav)
        nav.navigationItem
        
        vc.present(nav, animated: true, completion: nil)
    }
    
}
