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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
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
            print("Updated User")
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
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}



