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
    
    static func parseClassName() -> String {
        return "WorkOrders"
    }
    
    var customerName : String! {
        get {return object(forKey: "customerName") as! String}
        set { setObject(newValue, forKey: "customerName") }
    }
    
    var customerAddress : String! {
        get {return object(forKey: "customerAddress") as! String}
        set { setObject(newValue, forKey: "customerAddress") }
    }
    
    var customerPhone : String! {
        get {return object(forKey: "customerPhone") as! String}
        set { setObject(newValue, forKey: "customerPhone") }
    }
    
    var customerAltPhone : String? {
        get {return object(forKey: "customerAltPhone") as? String}
        set { setObject(newValue!, forKey: "customerAltPhone") }
    }
    
    var date : Date! {
        get {return object(forKey: "date") as! Date}
        set { setObject(newValue, forKey: "date") }
    }
    
    var status : String? {
        get {return object(forKey: "status") as? String}
        set { setObject(newValue!, forKey: "status") }
    }
    
    var schedTime : Date? {
        get {return object(forKey: "schedTime") as? Date}
        set { setObject(newValue!, forKey: "schedTime") }
    }
    
    var technician : String? {
        get {return object(forKey: "technician") as? String}
        set { setObject(newValue!, forKey: "technician") }
    }
    
    var technicianPointer : Employee? {
        get {return object(forKey: "technicianPointer") as? Employee}
        set { setObject(newValue!, forKey: "technicianPointer") }
    }
    
    var workToBePerformed : String? {
        get {return object(forKey: "workToBePerformed") as? String}
        set { setObject(newValue!, forKey: "workToBePerformed") }
    }
    
    var descOfWork : String? {
        get {return object(forKey: "descOfWork") as? String}
        set { setObject(newValue!, forKey: "descOfWork") }
    }
    
    var unitMake : String? {
        get {return object(forKey: "unitMake") as? String}
        set { setObject(newValue!, forKey: "unitMake") }
    }
    
    var unitModel : String? {
        get {return object(forKey: "unitModel") as? String}
        set { setObject(newValue!, forKey: "unitModel") }
    }
    
    var unitSerial : String? {
        get {return object(forKey: "unitSerial") as? String}
        set { setObject(newValue!, forKey: "unitSerial") }
    }
    
    var parts : NSArray? {
        get {return object(forKey: "parts") as? NSArray}
        set { setObject(newValue!, forKey: "parts") }
    }
    
    var labor : NSArray? {
        get {return object(forKey: "labor") as? NSArray}
        set { setObject(newValue!, forKey: "labor") }
    }
    
    var mobileTechObject : [PFObject]? {
        get {return object(forKey: "mobileTechObject") as? [PFObject]}
        set { setObject(newValue!, forKey: "mobileTechObject") }
    }
    
}
