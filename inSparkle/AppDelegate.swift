//
//  AppDelegate.swift
//  inSparkle
//
//  Created by Trever on 11/12/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import UIKit
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
        
        if getSSID() == "Sparkle Pools" {
            print(getSSID())
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://10.0.1.9:1337/parse"
            }
            Parse.initialize(with: configuration)
        } else {
            print(getSSID())
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://insparklepools.com:1337/parse"
            }
            Parse.initialize(with: configuration)
        }
        
        registerParseSubclasses()
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
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
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            
        })
        application.registerForRemoteNotifications()
        
        print(PFInstallation.current()?.deviceToken)
        PFInstallation.current()?.saveEventually()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append(LoginViewController.self)
        IQKeyboardManager.sharedManager().disabledToolbarClasses.append(LoginViewController.self)
        
        DropDown.startListeningToKeyboard()
        
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
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()!
        
        if PFUser.current() != nil {
            let employee = PFUser.current()?.object(forKey: "employee") as? Employee
            print(PFUser.current())
            print(employee)
            
            if employee != nil {
                do {
                    try employee!.fetchIfNeeded()
                } catch {
                    print(error)
                }
                
                installation.setObject(employee!, forKey: "employee")
            }
        }
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print(UIDevice.current.name)
        
        if UIDevice.current.name == "Store iPad 1" || UIDevice.current.name == "Store iPad 2" || UIDevice.current.name == "iPhone Simulator"{
            if PFUser.current() != nil {
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
        
        let apiKey = "AIzaSyAW7Mk3n17qA3Wdn2gJxkjqput1AwwVrcI"
        let location = "39.493115,-87.378896"
        let timeStamp = String(Date().timeIntervalSince1970)
        
        let url = "https://maps.googleapis.com/maps/api/timezone/json?location=\(location)&timestamp=\(timeStamp)&key=\(apiKey)"
        
        Alamofire.request(url)
        .responseJSON { (response) in
            if let json = response.result.value as? NSDictionary {
                let timeZoneOffset = json["rawOffset"]! as! Int
                UserDefaults.standard.set(timeZoneOffset, forKey: "SparkleTimeZone")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        if application.applicationState == .active {
            let currentInstall = PFInstallation.current()!
            if currentInstall.badge != 0 {
                currentInstall.badge = 0
                currentInstall.saveEventually()
            }
        }
        
        if let aps = userInfo["aps"] as? NSDictionary {
            
            if let vc = userInfo["vc"] as? String {
                
                if vc == "messages" {
                    let messageID = userInfo["messageID"] as! String
                    handleDeepLinkForMessages(messageID)
                }
                
            }
        }
    }
    
    func handleDeepLinkForMessages(_ messageID : String) {
        
        if self.window!.rootViewController as? UITabBarController != nil {
            let tabBarController = self.window?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 2
        }
        
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
}





