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
import MKRingProgressView

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var helloTextView: UITextView!
    
    @IBOutlet weak var addButton: SpringButton!
    @IBOutlet weak var messageLabel: SpringLabel!
    @IBOutlet weak var pocLabel: SpringLabel!
    @IBOutlet weak var workOrderLabel: SpringLabel!
    @IBOutlet weak var soiLabel: SpringLabel!
    @IBOutlet weak var nextAvailLabel: UILabel!
    
    @IBOutlet weak var messageButton: SpringButton!
    @IBOutlet weak var pocButton: SpringButton!
    @IBOutlet weak var woButton: SpringButton!
    @IBOutlet weak var soiButton: SpringButton!
    
    @IBOutlet weak var allAddView: SpringView!
    
    @IBOutlet weak var workOrderProgressView: MKRingProgressView!
    @IBOutlet weak var pocProgressView: MKRingProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workOrderProgressRingQuery()
        pocProgressRingQuery()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        workOrderProgressRingQuery()
        pocProgressRingQuery()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.workOrderProgressView.progress = 0
        self.pocProgressView.progress = 0
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func workOrderProgressRingQuery() {
        let query = WorkOrders.query()!
        query.countObjectsInBackground { (total : Int32, error : Error?) in
            if error == nil {
                let totalAssigned = Int(total)
                
                let exclude = ["Billed", "Do not Bill", "Completed"]
                query.whereKey("status", notContainedIn: exclude)
                query.countObjectsInBackground(block: { (left : Int32, error2 : Error?) in
                    if error2 == nil {
                        let leftToDo = Int(left)
                        
                        let percent : Double = ( Double(totalAssigned - leftToDo) / Double(totalAssigned) )
                        self.workOrderProgressView.progress = percent
                        
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                        label.text = "\(leftToDo)"
                        label.font = UIFont.systemFont(ofSize: 32)
                        label.sizeToFit()
                        label.textColor = UIColor.black
                        label.center = self.workOrderProgressView.center
                        
                        self.view.addSubview(label)
                    }
                })
            }
        }
    }
    
    func pocProgressRingQuery() {
        let query = WeekList.query()!
        query.whereKey("weekEnd", greaterThanOrEqualTo: Date())
        query.whereKey("apptsRemain", greaterThan: 0)
        query.getFirstObjectInBackground { (firstWeek : PFObject?, error : Error?) in
            if error == nil {
                if firstWeek != nil {
                    let week = firstWeek as! WeekList
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    var startWeek = dateFormatter.string(from: week.weekStart)
                    let endRange = startWeek.endIndex
                    let startRange = startWeek.characters.index(startWeek.endIndex, offsetBy: -6)
                    
                    startWeek.removeSubrange(startRange..<endRange)
                    
                    var endWeek = dateFormatter.string(from: week.weekEnd)
                    let endWeekEndRange = endWeek.endIndex
                    endWeek.removeSubrange(startRange..<endWeekEndRange)
                    endWeek.characters.removeLast()
                    print(endWeek)
                    
                    let max = week.maxAppts
                    let remain = week.apptsRemain
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    label.text = String(remain)
                    label.font = UIFont.systemFont(ofSize: 32)
                    label.sizeToFit()
                    label.textColor = UIColor.black
                    label.center = self.pocProgressView.center
                    label.numberOfLines = 0
                    
                    self.view.addSubview(label)
                    
                    if week.isOpenWeek {
                        self.nextAvailLabel.text = "Next Available Opening Week:\n"  + startWeek + " - " + endWeek
                    } else {
                        self.nextAvailLabel.text = "Next Available Closing Week:\n" + startWeek + " - " + endWeek
                    }
                    
                    let percent = Double(week.numApptsSch) / Double(max)
                    
                    self.pocProgressView.progress = percent

                }
            }
        }
    }
    
    func setUpHello() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            self.helloTextView.text = "Good morning,\n" + EmployeeData.universalEmployee.firstName.capitalized + "."
        }
        
        if hour >= 12 && hour <= 17 {
            self.helloTextView.text = "Good afternoon,\n"  + EmployeeData.universalEmployee.firstName.capitalized + "."
        }
        
        if hour > 17 {
            self.helloTextView.text = "Good evening,\n" + EmployeeData.universalEmployee.firstName.capitalized + "."
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

extension Notification {
    
   static func string(name: String) -> Notification.Name {
        return Notification.Name(rawValue: name)
    }
    
}
