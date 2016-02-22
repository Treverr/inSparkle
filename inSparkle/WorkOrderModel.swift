//
//  WorkOrderModel.swift
//  inSparkle
//
//  Created by Trever on 2/15/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class WorkOrders : PFObject, PFSubclassing {
    
    override class func initialize() {
        self.registerSubclass()
    }
    
    static func parseClassName() -> String {
        return "WorkOrders"
    }
    
    var customerName : String! {
        get {return objectForKey("customerName") as! String}
        set { setObject(newValue, forKey: "customerName") }
    }
    
    var customerAddress : String! {
        get {return objectForKey("customerAddress") as! String}
        set { setObject(newValue, forKey: "customerAddress") }
    }
    
    var customerAddressCity : String! {
        get {return objectForKey("customerAddressCity") as! String}
        set { setObject(newValue, forKey: "customerAddressCity") }
    }
    
    var customerPhone : String! {
        get {return objectForKey("customerPhone") as! String}
        set { setObject(newValue, forKey: "customerPhone") }
    }
    
    var customerAltPhone : String? {
        get {return objectForKey("customerAltPhone") as? String}
        set { setObject(newValue!, forKey: "customerAltPhone") }
    }
    
    var date : NSDate! {
        get {return objectForKey("date") as! NSDate}
        set { setObject(newValue, forKey: "date") }
    }
    
    var status : String {
        get {return objectForKey("status") as! String}
        set { setObject(newValue, forKey: "status") }
    }
    
    var schedTime : NSDate? {
        get {return objectForKey("schedTime") as? NSDate}
        set { setObject(newValue!, forKey: "schedTime") }
    }
    
    var technician : String? {
        get {return objectForKey("technician") as? String}
        set { setObject(newValue!, forKey: "technician") }
    }
    
    var workToBePerformed : String? {
        get {return objectForKey("workToBePerformed") as? String}
        set { setObject(newValue!, forKey: "workToBePerformed") }
    }
    
    var descOfWork : String? {
        get {return objectForKey("descOfWork") as? String}
        set { setObject(newValue!, forKey: "descOfWork") }
    }
    
    var reccomendation : String? {
        get {return objectForKey("reccomendation") as? String}
        set { setObject(newValue!, forKey: "reccomendation") }
    }
    
    var tripOneDate : NSDate? {
        get {return objectForKey("tripOneDate") as? NSDate}
        set { setObject(newValue!, forKey: "tripOneDate") }
    }
    
    var tripOneTimeArrival : NSDate? {
        get {return objectForKey("tripOneTimeArrival") as? NSDate}
        set { setObject(newValue!, forKey: "tripOneTimeArrival") }
    }
    
    var tripOneTimeDepart : NSDate? {
        get {return objectForKey("tripOneTimeDepart") as? NSDate}
        set { setObject(newValue!, forKey: "tripOneTimeDepart") }
    }
    
    var tripTwoTimeArrival : NSDate? {
        get {return objectForKey("tripTwoTimeArrival") as? NSDate}
        set { setObject(newValue!, forKey: "tripTwoTimeArrival") }
    }
    
    var tripTwoTimeDepart : NSDate? {
        get {return objectForKey("tripTwoTimeDepart") as? NSDate}
        set { setObject(newValue!, forKey: "tripTwoTimeDepart") }
    }
    
    var unitMake : String? {
        get {return objectForKey("unitMake") as? String}
        set { setObject(newValue!, forKey: "unitMake") }
    }
    
    var unitModel : String? {
        get {return objectForKey("unitModel") as? String}
        set { setObject(newValue!, forKey: "unitModel") }
    }
    
    var unitSerial : String? {
        get {return objectForKey("unitSerial") as? String}
        set { setObject(newValue!, forKey: "unitSerial") }
    }
    
    var parts : NSArray? {
        get {return objectForKey("parts") as? NSArray}
        set { setObject(newValue!, forKey: "parts") }
    }
    
    var labor : NSArray? {
        get {return objectForKey("labor") as? NSArray}
        set { setObject(newValue!, forKey: "labor") }
    }
}