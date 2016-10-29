//
//  MoreTableViewController.swift
//  inSparkle
//
//  Created by Trever on 11/17/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Parse
class MoreTableViewController: UITableViewController {
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet var adminButton: UIBarButtonItem!
    @IBOutlet var profileLabel: UILabel!
    
    var specialAccess : [String]! = []
    var printerSelectionRect : CGRect!
    
    override func viewDidLoad() {
        self.navigationController?.setupNavigationbar(self.navigationController!)
        
        if PFUser.current()?.object(forKey: "specialAccess") != nil {
            self.specialAccess = PFUser.current()?.object(forKey: "specialAccess") as! [String]
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MoreTableViewController.signBackIn), name: NSNotification.Name(rawValue: "SignBackIn"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var wasAdmin : Bool!
        var spec : [String] = self.specialAccess
        var origSec = self.tableView.numberOfSections
        
        do {
            try PFUser.current()?.fetch()
            
            if PFUser.current()?.object(forKey: "specialAccess") != nil {
                self.specialAccess = PFUser.current()?.object(forKey: "specialAccess") as! [String]
            }
        } catch { }
        
        if (PFUser.current()?.value(forKey: "isAdmin") as! Bool) == false {
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
        } else {
            self.navigationItem.rightBarButtonItem = adminButton
            self.tableView.reloadData()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if PFUser.current() != nil {
            if (PFUser.current()?.value(forKey: "isAdmin") as! Bool) == true {
                return 1
            } else {
                return 2
            }
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else {
            return specialAccess.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && specialAccess.count > 1 {
            return "Special Access"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "timeClock")!
            case 1:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "pdfLocker")!
            case 2:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "sparkleConnect")!
            case 3:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "customerLookup")!
            case 4:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "printerSelection")!
                self.printerSelectionRect = cell.frame
            case 5:
                cell = self.tableView.dequeueReusableCell(withIdentifier: "logoutCell")!
            default:
                break
            }
            
        } else {
            if (indexPath as NSIndexPath).section == 1 {
                cell = self.tableView.dequeueReusableCell(withIdentifier: "saCell")!
                cell.textLabel?.text = specialAccess[(indexPath as NSIndexPath).row]
                cell.accessoryType = .disclosureIndicator

                switch specialAccess[(indexPath as NSIndexPath).row] {
                case "Manage Users and Employees":
                    cell.imageView?.image = UIImage(named: "Manage Users")
                case "Time Card Management":
                    cell.imageView?.image = UIImage(named: "TimeCard")
                case "Chemical Checkout Reports":
                    cell.imageView?.image = UIImage(named: "Chemical Checkout Report")
                case "Pool Opening Closing Reports":
                    cell.imageView?.image = UIImage(named: "POCReport")
                case "Time Card Reports":
                    cell.imageView?.image = UIImage(named: "Clock")
                default:
                    break
                }
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.tableView.cellForRow(at: indexPath)
        
        if cell?.reuseIdentifier == "timeClock" {
            if let appURL = URL(string: "mysparklepoolstime://") {
                if UIApplication.shared.canOpenURL(appURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    let alert = UIAlertController(title: "TIME is not installed on your device", message: "\nContact IS&T to have TIME pushed to your device or clock out on the Time Clock", preferredStyle: .alert)
                    let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(okayButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        if cell?.reuseIdentifier == "customerLookup" {
            CustomerLookupObjects.fromVC = "More"
        }
        
        if cell?.reuseIdentifier == "logoutCell" {
            self.logoutAction(self)
        }
        
        if cell?.reuseIdentifier == "printerSelection" {
            selectPrinter()
        }
        
        if (indexPath as NSIndexPath).section == 1 {
            switch cell!.textLabel!.text! {
            case "Manage Users and Employees":
                let sb = UIStoryboard(name: "Manage Emps", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "manageEmpsNav") as! UINavigationController
                self.present(vc, animated: true, completion: nil)
            case "Time Card Management":
                let sb = UIStoryboard(name: "TimeCardManagement", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "timeCardManageNav") as! UINavigationController
                self.present(vc, animated: true, completion: nil)
            case "Chemical Checkout Reports":
                let sb = UIStoryboard(name: "ChemicalCheckoutReport", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "chemCheckoutNav") as! UINavigationController
                self.present(vc, animated: true, completion: nil)
            case "Pool Opening Closing Reports":
                let sb = UIStoryboard(name: "POCReport", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "pocReportNav") as! UINavigationController
                self.present(vc, animated: true, completion: nil)
            case "Time Card Reports":
                let sb = UIStoryboard(name: "TimeClockReport", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "timeCardReportNav") as! UINavigationController
                self.present(vc, animated: true, completion: nil)
            default:
                break
            }
            
        }
        
    }
    
    func selectPrinter() {
        var printer : UIPrinter! = nil
        
        if UserDefaults.standard.object(forKey: "printer") != nil {
            printer = UIPrinter(url: UserDefaults.standard.url(forKey: "printer")!)
        }
        
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: printer)
        printerPicker.present(from: self.printerSelectionRect, in: self.view, animated: true) { (picker, selected, error) in
            if selected {
                UserDefaults.standard.set(printerPicker.selectedPrinter?.url, forKey: "printer")
                picker.dismiss(animated: true)
            }
        }
        
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        
        PFUser.logOut()
        
        DispatchQueue.main.async { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login") 
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func supportAction(_ sender: AnyObject) {
        
    }
    
    func setUserName() {
        if EmployeeData.universalEmployee != nil {
            let empl = EmployeeData.universalEmployee as Employee
            let name = empl.firstName + " " + empl.lastName
            self.profileLabel.text = name
        }
    }
    
    func signBackIn() {
        PFSession.getCurrentSessionInBackground { (session : PFSession?, error : Error?) in
            if error != nil {
                PFUser.logOut()
                let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                self.present(viewController, animated: true, completion: nil)
            } else {
                let currentUser : PFUser?
                
                currentUser = PFUser.current()
                let currentSession = PFUser.current()?.sessionToken
                
                if (currentUser == nil) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                        self.present(viewController, animated: true, completion: nil)
                    })
                }
                
                if (currentUser?.sessionToken == nil) {
                    PFUser.logOut()
                    let viewController : UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
