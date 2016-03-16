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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var logOutTimer : NSTimer?
    
    let locationManager = CLLocationManager()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        
        registerParseSubclasses()
        
        Parse.setApplicationId("M8DKwA6ifp1JJlHmSjpBL0M66tYq710f9xEnFcrv",
                               clientKey: "cy4fwRWmKVdFw8LSCCjYIflbH2yP6qCjWQnoAMzH")
        
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
                Crashlytics.sharedInstance().setUserIdentifier(employee?.firstName)
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
    
    func applicationWillResignActive(application: UIApplication) {
        //        logOutTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "logOut", userInfo: nil, repeats: false)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        logOutTimer?.invalidate()
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
            let viewController:UIViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
            let currentView = self.window?.rootViewController
            currentView!.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
}



