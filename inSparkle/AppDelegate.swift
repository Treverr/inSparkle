//
//  AppDelegate.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
import Foundation
import Parse
import Bolts
import Fabric
import Crashlytics
import CoreLocation
import IQKeyboardManagerSwift
import BRYXBanner
import SystemConfiguration.CaptiveNetwork
import DropDown
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var logOutTimer : Timer?
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = sb.instantiateViewController(withIdentifier: "mainTabBar") as! TabBarViewController
            
            self.window?.rootViewController = tabBar
        }
        
        //        else if UIDevice.current.userInterfaceIdiom == .pad {
        //            let sb = UIStoryboard(name: "Main", bundle: nil)
        //            let tabBar = sb.instantiateViewController(withIdentifier: "ipadMain")
        //            self.window?.rootViewController = tabBar
        //        }
        
        if getSSID() == "Sparkle Pools" {
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://10.0.1.9:1337/parse"
            }
            Parse.initialize(with: configuration)
        } else {
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://ps.mysparklepools.com:1337/parse"
            }
            Parse.initialize(with: configuration)
        }
        
        registerParseSubclasses()
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        GlobalFunctions().checkLogin()
        
        if PFUser.current() != nil {
            do {
                try PFUser.current()?.fetch()
                if PFUser.current() != nil {
                    let employee = PFUser.current()?.object(forKey: "employee") as? Employee
                    do {
                        try employee!.fetch()
                    } catch {
                        print(error)
                    }
                    
                    EmployeeData.universalEmployee = employee
                    Crashlytics.sharedInstance().setUserIdentifier(employee?.firstName)
                    Crashlytics.sharedInstance().setUserEmail(PFUser.current()?.email)
                    
                }
            } catch {
                let errorAlert = UIAlertController(title: "Error", message: "There was an error retrieving your user information, please try again. If the issue continues please contact IS&T", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    PFUser.logOut()
                })
                errorAlert.addAction(okayButton)
                self.window?.rootViewController?.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            
        })
        application.registerForRemoteNotifications()
        
        PFInstallation.current()?.saveEventually()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(LoginViewController.self)
        IQKeyboardManager.sharedManager().disabledToolbarClasses.append(LoginViewController.self)
        
        DropDown.startListeningToKeyboard()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        if let launchOptions = launchOptions {
            if let apns = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                if let remoteApproval = apns["remoteApprovalID"] as? String {
                    print(remoteApproval)
                    handleActiveRemoteApproval(remoteID: remoteApproval)
                }
            }
        }
        
        return true
    }
    
    func displayGlobalMessages() {
        
        let defaults = UserDefaults.standard
        let globalMessageDisplayed = defaults.bool(forKey: "globalMessageDisplayed")
        
        
        if PFConfigs.config != nil {
            
            if globalMessageDisplayed {
                
                if defaults.value(forKey: "globalMessage") as! String != PFConfigs.config["globalMessage"] as! String {
                    defaults.set(false, forKey: "globalMessageDisplayed")
                    displayGlobalMessages()
                }
                
            } else {
                let message = PFConfigs.config["globalMessage"]! as! String
                
                let globalMessage = UIAlertController(title: "Global Message", message: message, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                globalMessage.addAction(okay)
                self.window?.rootViewController?.present(globalMessage, animated: true, completion: {
                    defaults.set(true, forKey: "globalMessageDisplayed")
                    defaults.setValue(message, forKey: "globalMessage")
                })
            }
        }
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory + "/PDFLocker"
        if FileManager.default.fileExists(atPath: documentsDirectory + "/PDFLocker") {
            var fileName = String(describing: url).components(separatedBy: "/").last
            fileName = fileName?.removingPercentEncoding
            let origPath = String(describing: url).components(separatedBy: "/Inbox/").first!.components(separatedBy: "file://").last
            var originalFilePath = String(describing: url).components(separatedBy: ("file://")).last!
            originalFilePath = originalFilePath.removingPercentEncoding!
            let newPath = origPath! + "/PDFLocker/" + fileName!
            do {
                try FileManager.default.copyItem(atPath: originalFilePath, toPath: newPath)
            } catch {
                print(error)
            }
            
        } else {
            
            do {
                try FileManager.default.createDirectory(atPath: inboxPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                
            }
            
            var fileName = String(describing: url).components(separatedBy: "/").last
            fileName = fileName?.removingPercentEncoding
            let origPath = String(describing: url).components(separatedBy: "/Inbox/").first!.components(separatedBy: "file://").last
            var originalFilePath = String(describing: url).components(separatedBy: ("file://")).last!
            originalFilePath = originalFilePath.removingPercentEncoding!
            let newPath = origPath! + "/PDFLocker/" + fileName!
            do {
                try FileManager.default.copyItem(atPath: originalFilePath, toPath: newPath)
            } catch {
                print(error)
            }
        }
        
        
        
        let rootView = self.window!.rootViewController as! TabBarViewController
        rootView.selectedIndex = 4
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navVC: UINavigationController =  rootView.viewControllers![4] as! UINavigationController
        storyBoard.instantiateViewController(withIdentifier: "moreView") as! MoreTableViewController
        print(navVC.topViewController?.description)
        if navVC.topViewController!.description.contains("inSparkle.MoreTableViewController") {
            let vc = navVC.topViewController as! MoreTableViewController
            
            
            let pdfLockerSB = UIStoryboard(name: "PDFLocker", bundle: nil)
            let pdfvc = pdfLockerSB.instantiateViewController(withIdentifier: "pdfLockerTable") as! PDFLockerTableViewController
            
            vc.navigationController?.pushViewController(pdfvc, animated: true)
            
        }
        
        return true
    }
    
    func registerParseSubclasses() {
        Logs.registerSubclass()
        WorkOrders.registerSubclass()
        ScheduleObject.registerSubclass()
        TimeClockPunchObj.registerSubclass()
        TimePunchCalcObject.registerSubclass()
        CustomerData.registerSubclass()
        WeekList.registerSubclass()
        Employee.registerSubclass()
        Messages.registerSubclass()
        MessageNotes.registerSubclass()
        SpecialAccessObj.registerSubclass()
        Role.registerSubclass()
        TimeAwayRequest.registerSubclass()
        VacationTime.registerSubclass()
        VacationTimePunch.registerSubclass()
        SOIObject.registerSubclass()
        SessionModel.registerSubclass()
        WorkServiceOrderTimeLog.registerSubclass()
        RemoteApproveRequest.registerSubclass()
        ExpenseLog.registerSubclass()
        ExpenseItem.registerSubclass()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()!
        
        if PFUser.current() != nil {
            let employee = PFUser.current()?.object(forKey: "employee") as? Employee
            
            if employee != nil {
                
                do {
                    try employee!.fetchIfNeeded()
                } catch {
                    print(error)
                }
                
                installation.setObject(employee!, forKey: "employee")
                installation.setObject(employee!.objectId! as String, forKey: "employeeid")
            }
        }
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print(UIDevice.current.name)
        
        if UIDevice.current.name == "Store iPad 1" || UIDevice.current.name == "Store iPad 2" || UIDevice.current.name == "iPhone Simulator"{
            if PFUser.current() != nil {
                PFInstallation.current()?.remove(forKey: "employee")
                PFInstallation.current()?.saveInBackground()
                self.logOut()
            }
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if PFUser.current() != nil {
            let employee = PFUser.current()?.object(forKey: "employee")
            (employee as AnyObject).fetchIfNeededInBackground(block: { (emp : PFObject?, error : Error?) in
                if error == nil {
                    let theEmployee = emp as! Employee
                    let name = theEmployee.firstName
                    
                    let banner = Banner(title: "Welcome Back, \(name)!", subtitle: nil, image: nil, backgroundColor: Colors.sparkleBlue, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.dismissesOnSwipe = true
                    banner.show(duration: 1.25)
                }
            })
            
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        do {
            PFConfigs.config = try PFConfig.getConfig()
        } catch {
            
        }
        
        //        displayGlobalMessages()
        
        let currentInstallation = PFInstallation.current()!
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let timeZone = TimeZone(identifier: "America/Indiana/Indianapolis")
        SparkleTimeZone.timeZone = timeZone!
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        print(userInfo)
        if application.applicationState == .active {
            let currentInstall = PFInstallation.current()!
            if currentInstall.badge != 0 {
                currentInstall.badge = 0
                currentInstall.saveEventually()
            }
        }
        
        if let remoteApproval = userInfo["remoteApprovalID"] as? String {
                handleActiveRemoteApproval(remoteID: remoteApproval)
        }
    
    }
    
    func handleDeepLinkForMessages(_ messageID : String) {
        
        if self.window!.rootViewController as? UITabBarController != nil {
            let tabBarController = self.window?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 2
        }
        
    }
    
    func handleActiveRemoteApproval(remoteID : String) {
        let remoteQuery = RemoteApproveRequest.query()
        remoteQuery?.includeKey("requestedBy")
        remoteQuery?.getObjectInBackground(withId: remoteID, block: { (remoteObject, error) in
            if error == nil {
                let object = remoteObject as! RemoteApproveRequest
                
                if object.response == nil {
                    let reason = object.requestedBy.firstName.capitalized + " has requested an override for " + object.requestReason.lowercased()
                    
                    let alert = UIAlertController(title: "Remote Manager Approval", message: reason, preferredStyle: .alert)
                    let approveAction = UIAlertAction(title: "Approve", style: .default, handler: { (action) in
                        object.response = "Approved"
                        object.respondedBy = EmployeeData.universalEmployee
                        object.saveInBackground()
                    })
                    let denyAction = UIAlertAction(title: "Deny", style: .destructive, handler: { (action) in
                        object.response = "Denied"
                        object.respondedBy = EmployeeData.universalEmployee
                        object.saveInBackground()
                    })
                    let ignoreAction = UIAlertAction(title: "Ignore", style: .default, handler: nil)
                    
                    alert.addAction(approveAction)
                    alert.addAction(denyAction)
                    alert.addAction(ignoreAction)
                    
                    GlobalFunctions().displayAlertOverMainWindow(alert: alert)
                } else {
                    let message = "This request has already been" + object.response!.lowercased() + " by " + object.respondedBy!.firstName.capitalized
                    let alert = UIAlertController(title: "Remote Manager Approval", message: message, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    
                    alert.addAction(okay)
                    GlobalFunctions().displayAlertOverMainWindow(alert: alert)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error as! String?, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okay)
                GlobalFunctions().displayAlertOverMainWindow(alert: alert)
            }

        })
    }
    
    func logOut() {
        PFUser.logOut()
        
        DispatchQueue.main.async { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login")
            let currentView = self.window?.currentViewController()
            currentView?.present(viewController, animated: true, completion: nil)
        }
    }
    
    func getSSID() -> String? {
        
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil {
            return nil
        }
        
        let interfacesArray = interfaces as! [String]
        if interfacesArray.count <= 0 {
            return nil
        }
        
        let interfaceName = interfacesArray[0] as String
        let unsafeInterfaceData =     CNCopyCurrentNetworkInfo(interfaceName as CFString)
        if unsafeInterfaceData == nil {
            return nil
        }
        
        let interfaceData = unsafeInterfaceData as! Dictionary <String,AnyObject>
        
        return interfaceData["SSID"] as? String
    }
    
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
}



