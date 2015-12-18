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
        
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringForRegion(regionWithGeotification())
        let currentLoc = locationManager.location
        print(currentLoc)
        
        
        return true
    }
    
    func registerParseSubclasses() {
        ScheduleObject.registerSubclass()
        TimeClockPunchObj.registerSubclass()
        TimePunchCalcObject.registerSubclass()
        CustomerData.registerSubclass()
        WeekList.registerSubclass()
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
            if region.identifier == "Sparkle" {
                let notification = UILocalNotification()
                notification.alertBody = "Don't forget to punch in!"
                notification.regionTriggersOnce = false
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Sparkle" {
            let notification = UILocalNotification()
            notification.alertBody = "Don't forget to punch out!"
            notification.regionTriggersOnce = false
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func regionWithGeotification() -> CLCircularRegion {
        // 1
        let sparkle = CLLocationCoordinate2DMake(39.4931129, -87.3790228)
        let region = CLCircularRegion(center: sparkle, radius: 200, identifier: "Sparkle")
        // 2
        region.notifyOnEntry = region.notifyOnEntry
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
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



