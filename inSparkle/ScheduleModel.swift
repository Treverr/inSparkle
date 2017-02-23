//
//  ScheduleModel.swift
//  inSparkle
//
//  Created by Trever on 12/3/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class ScheduleObject : PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Schedule"
    }
    
    var accountNumber : String? {
        get { return object(forKey: "accountNumber") as? String }
        set { setObject(newValue!, forKey: "accountNumber") }
    }
    
    var customerName : String {
        get { return object(forKey: "customerName") as! String }
        set { setObject(newValue, forKey: "customerName") }
    }
    
    var customerAddress : String {
        get { return object(forKey: "customerAddress") as! String }
        set { setObject(newValue, forKey: "customerAddress") }
    }
    
    var customerPhone : String {
        get { return object(forKey: "customerPhone") as! String }
        set { setObject(newValue, forKey: "customerPhone") }
    }
    
    var weekStart : Date {
        get { return object(forKey: "weekStart") as! Date }
        set { setObject(newValue, forKey: "weekStart") }
    }
    
    var weekEnd : Date {
        get { return object(forKey: "weekEnd") as! Date }
        set { setObject(newValue, forKey: "weekEnd") }
    }
    
    var isActive : Bool {
        get { return object(forKey: "isActive") as! Bool }
        set { setObject(newValue, forKey: "isActive") }
    }
    
    var cancelReason : String? {
        get { return object(forKey: "cancelReason") as? String }
        set { setObject(newValue!, forKey: "cancelReason") }
    }
    
    var type : String {
        get { return object(forKey: "type") as! String }
        set { setObject(newValue, forKey: "type") }
    }
    
    var coverType : String {
        get { return object(forKey: "coverType") as! String }
        set { setObject(newValue, forKey: "coverType") }
    }
    
    var aquaDoor : Bool? {
        get { return object(forKey: "aquaDoor") as? Bool }
        set { setObject(newValue!, forKey: "aquaDoor") }
    }
    
    var locEssentials : String {
        get { return object(forKey: "locEssentials") as! String }
        set { setObject(newValue, forKey: "locEssentials") }
    }
    
    var bringChem : Bool {
        get { return object(forKey: "bringChem") as! Bool }
        set { setObject(newValue, forKey: "bringChem") }
    }
    
    var takeTrash : Bool {
        get { return object(forKey: "takeTrash") as! Bool }
        set { setObject(newValue, forKey: "takeTrash") }
    }
    
    var notes : String? {
        get { return object(forKey: "notes") as? String }
        set { setObject(newValue!, forKey: "notes") }
    }
    
    var canceledBy : String? {
        get { return object(forKey: "canceledBy") as? String }
        set { setObject(newValue!, forKey: "canceledBy") }
    }
    
    var confrimed : Bool? {
        get { return object(forKey: "confrimed") as? Bool }
        set { setObject(newValue!, forKey: "confrimed") }
    }
    
    var confrimedBy : String? {
        get { return object(forKey: "confrimedBy") as? String }
        set { setObject(newValue!, forKey: "confrimedBy") }
    }
    
    var confirmedDate : Date? {
        get { return object(forKey: "confirmedDate") as? Date }
        set { setObject(newValue!, forKey: "confirmedDate") }
    }
    
    var confirmedWith : String? {
        get { return object(forKey: "confirmedWith") as? String }
        set { setObject(newValue!, forKey: "confirmedWith") }
    }
    
    var weekObj : WeekList {
        get { return object(forKey: "weekObj") as! WeekList }
        set { setObject(newValue, forKey: "weekObj") }
    }
    
    var tentativeDate : WeekList? {
        get { return object(forKey: "weekObj") as? WeekList }
        set { setObject(newValue!, forKey: "weekObj") }
    }
    
    var smsEnabled : Bool? {
        get { return object(forKey: "smsEnabled") as? Bool }
        set { setObject(newValue!, forKey: "smsEnabled") }
    }
    
    var smsNumber : String? {
        get { return object(forKey: "smsNumber") as? String }
        set { setObject(newValue!, forKey: "smsNumber") }
    }
    
    var smsCustomerNotified : Bool? {
        get { return object(forKey: "smsCustomerNotified") as? Bool }
        set { setObject(newValue!, forKey: "smsCustomerNotified") }
    }
    
}
