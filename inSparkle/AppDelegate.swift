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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var logOutTimer : NSTimer?
    
    let locationManager = CLLocationManager()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if getSSID() == "Sparkle Pools" {
            print(getSSID())
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://10.0.1.9:1337/parse"
            }
            Parse.initializeWithConfiguration(configuration)
        } else {
            print(getSSID())
            let configuration = ParseClientConfiguration {
                $0.applicationId = "inSparkle"
                $0.clientKey = ""
                $0.server = "http://insparklepools.com:1337/parse"
            }
            Parse.initializeWithConfiguration(configuration)
        }
        
        
        
        Fabric.with([Crashlytics.self])
        
        registerParseSubclasses()
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
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
                Crashlytics.sharedInstance().setUserIdentifier(employee?.firstName)
                Crashlytics.sharedInstance().setUserEmail(PFUser.currentUser()?.email)
                
            }
        } catch {
            print("Error")
        }
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        print(PFInstallation.currentInstallation().deviceToken)
        PFInstallation.currentInstallation().saveEventually()
        
        IQKeyboardManager.sharedManager().enable = true
        
        do {
            let config = try PFConfig.getConfig()
            let globalMsg = config["globalMessage"] as? String
            print(globalMsg!)
        } catch {
            
        }
        
        return true
    }
    
    func mobihelpIntegration(){
        var config : MobihelpConfig = MobihelpConfig(domain: "insparkle.freshdesk.com", withAppKey: "insparkle-2-eeccef6dda3ed4ae678466b2b0c5847e", andAppSecret: "51525287e07b865f00b5dfef42c3f2fe45a760a4")
        config.feedbackType = FEEDBACK_TYPE.NAME_AND_EMAIL_REQUIRED
        config.enableAutoReply = true // Enable Auto Reply.
        config.setThemeName("SparkleTheme")
        
        //Initialize Mobihelp. This needs to be called only once in the App.
        Mobihelp.sharedInstance().clearUserData()
        Mobihelp.sharedInstance().initWithConfig(config)
        Mobihelp.sharedInstance().userName = PFUser.currentUser()?.username!
        Mobihelp.sharedInstance().emailAddress = PFUser.currentUser()?.email!
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let inboxPath = documentsDirectory.stringByAppendingString("/PDFLocker")
        if NSFileManager.defaultManager().fileExistsAtPath(documentsDirectory.stringByAppendingString("/PDFLocker")) {
            var fileName = String(url).componentsSeparatedByString("/").last
            fileName = fileName?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            var origPath = String(url).componentsSeparatedByString("/Inbox/").first!.componentsSeparatedByString("file://").last
            var originalFilePath = String(url).componentsSeparatedByString(("file://")).last!
            originalFilePath = originalFilePath.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let newPath = origPath! + "/PDFLocker/" + fileName!
            do {
                try NSFileManager.defaultManager().copyItemAtPath(originalFilePath, toPath: newPath)
            } catch {
                print(error)
            }
            
        } else {
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(inboxPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                
            }
            
            var fileName = String(url).componentsSeparatedByString("/").last
            fileName = fileName?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            var origPath = String(url).componentsSeparatedByString("/Inbox/").first!.componentsSeparatedByString("file://").last
            var originalFilePath = String(url).componentsSeparatedByString(("file://")).last!
            originalFilePath = originalFilePath.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let newPath = origPath! + "/PDFLocker/" + fileName!
            do {
                try NSFileManager.defaultManager().copyItemAtPath(originalFilePath, toPath: newPath)
            } catch {
                print(error)
            }
        }
        
        
        
        let rootView = self.window!.rootViewController as! TabBarViewController
        rootView.selectedIndex = 4
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navVC: UINavigationController =  rootView.viewControllers![4] as! UINavigationController
        storyBoard.instantiateViewControllerWithIdentifier("moreView") as! MoreTableViewController
        print(navVC.topViewController?.description)
        if navVC.topViewController!.description.containsString("inSparkle.MoreTableViewController") {
            let vc = navVC.topViewController as! MoreTableViewController
            
            
            let pdfLockerSB = UIStoryboard(name: "PDFLocker", bundle: nil)
            let pdfvc = pdfLockerSB.instantiateViewControllerWithIdentifier("pdfLockerTable") as! PDFLockerTableViewController
            
            vc.navigationController?.pushViewController(pdfvc, animated: true)
            
        }
        
        return true
    }
    
    func registerParseSubclasses() {
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
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        
        if PFUser.currentUser() != nil {
            let employee = PFUser.currentUser()?.objectForKey("employee") as? Employee
            print(PFUser.currentUser())
            print(employee)
            
            do {
                try employee!.fetchIfNeeded()
            } catch { }
            
            installation.setObject(employee!, forKey: "employee")
        }
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
    }
    
    var nextFire : NSDate!
    
    func applicationWillResignActive(application: UIApplication) {
        
//        if UIDevice.currentDevice().name == "Store iPad 1" || UIDevice.currentDevice().name == "Store iPad 2" {
//            logOutTimer = NSTimer.scheduledTimerWithTimeInterval(100.0, target: self, selector: Selector(self.logOut()), userInfo: nil, repeats: false)
//        let timer = self.logOutTimer!
//        
//        nextFire = timer.fireDate
//        logOutTimer?.invalidate()
//        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        if PFUser.currentUser() != nil {
            var employee = PFUser.currentUser()?.objectForKey("employee")
            employee?.fetchIfNeededInBackgroundWithBlock({ (emp : PFObject?, error : NSError?) in
                if error == nil {
                    var theEmployee = emp as! Employee
                    let name = theEmployee.firstName
                    
                    let banner = Banner(title: "Welcome Back, \(name)!", subtitle: nil, image: nil, backgroundColor: Colors.sparkleBlue, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.dismissesOnSwipe = true
                    banner.show(duration: 1.25)
                }
            })
            
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
        if application.applicationState == .Active {
            let currentInstall = PFInstallation.currentInstallation()
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
    
    func handleDeepLinkForMessages(messageID : String) {
        
        if self.window!.rootViewController as? UITabBarController != nil {
            var tabBarController = self.window?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 2
        }
        
    }
    
    func logOut() {
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            let currentView = self.window?.currentViewController()
            currentView?.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func getSSID() -> String {
        
        var currentSSID = ""
        
        if let interfaces:CFArray! = CNCopySupportedInterfaces() {
            if interfaces != nil {
                for i in 0..<CFArrayGetCount(interfaces){
                    let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                    let rec = unsafeBitCast(interfaceName, AnyObject.self)
                    let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                    if unsafeInterfaceData != nil {
                        let interfaceData = unsafeInterfaceData! as Dictionary!
                        currentSSID = interfaceData["SSID"] as! String
                    }
                }
            } else {
                currentSSID = "Simulator"
            }
        }
        return currentSSID
    }
}





