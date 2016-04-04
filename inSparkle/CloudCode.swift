//
//  CloudCode.swift
//  inSparkle
//
//  Created by Trever on 12/13/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class CloudCode {
    
    class func AddUpdateCustomerRecord(accountNumber : String?, name : String, address : String, phoneNumber : String) {
        if accountNumber != nil {
            
            do {
                try PFCloud.callFunction("AddUpdateCustomerRecord", withParameters: [
                    "accountNumber" : accountNumber!,
                    "name1" : name,
                    "FullAddress" : address,
                    "cxPhoneNumber" : phoneNumber
                    ])
            } catch { }
        } else {
            do {
                try PFCloud.callFunction("AddUpdateCustomerRecord", withParameters: [
                    "name1" : name,
                    "FullAddress" : address,
                    "cxPhoneNumber" : phoneNumber
                    ])
            } catch { }
        }
    }
    
    class func AlertOfCancelation(name : String, address : String, phone : String, reason : String, cancelBy : String, theDates : String, theType : String) {
        do {
            try PFCloud.callFunction("AlertOfCancelation", withParameters: [
                "cxname" : name,
                "FullAddress" : address,
                "cxPhoneNumber" : phone,
                "cancelationReason" : reason,
                "whoCancel" : cancelBy,
                "theDates" : theDates,
                "theType" : theType,
                ])
        } catch { }
        
    }
    
    class func UpdateUserAdminStatus(username : String, adminStatus : Bool, alert : UIAlertController, completion : (complete : Bool) -> Void) {
        let parameters = [
        "username" : username,
        "adminStatus" : adminStatus,
        ]
        
        do {
            try PFCloud.callFunctionInBackground("modifyAdminStatus", withParameters: parameters as [NSObject : AnyObject], block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        } catch { }
        completion(complete: true)
    }
    
    class func UpdateUserInfo(username : String, email : String, objectId : String, completion : (isComplete : Bool) -> Void) {
        let params = [
        "username" : username,
        "emailAddy" : email,
        "objId" : objectId
        ]
        
        do {
            try PFCloud.callFunctionInBackground("updateUserInformation", withParameters: params, block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                    completion(isComplete: true)
                }
            })
        }
    }
    
    class func UpdateUserSpecialAccess(objId : String, specialAccesses : NSArray, completion : (isComplete : Bool) -> Void) {
        let params = [
            "objId" : objId,
            "specAccess" : specialAccesses,
        ]
        
        do {
            try PFCloud.callFunctionInBackground("UpdateUserSpecialAccess", withParameters: params, block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                    completion(isComplete: true)
                }
            })
        }
        
    }
    
    class func CreateNewUser(username : String, password : String, emailAddy : String, adminStatus : Bool, empID : String, completion : (isComplete : Bool, objectID : String) -> Void) {
        
        let params = [
            "username" : username,
            "password" : password,
            "emailAddy" : emailAddy,
            "adminStatus" : adminStatus,
            "empID" : empID,
        ]
        
        do {
            PFCloud.callFunctionInBackground("CreateNewUser", withParameters: params as [NSObject : AnyObject], block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                    completion(isComplete: true, objectID: response as! String)
                }
            })
        }
    }
    
    class func DeleteUser(userObjID : String, completion : (complete : Bool) -> Void) {
       let params = [
        "objId" : userObjID
        ]
        
        do {
            PFCloud.callFunctionInBackground("DeleteUser", withParameters: params, block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                   completion(complete: true)
                }
            })
        }
    }
    
    class func ChangeUserPassword(username : String, newPassword : String, completion: (isComplete : Bool) -> Void) {
        let params = [
            "username" : username,
            "newPassword" : newPassword
        ]
        
        PFCloud.callFunctionInBackground("changeUserPassword", withParameters: params) {
            (result: AnyObject?, error: NSError?) -> Void in
            if (error == nil) {
                completion(isComplete: true)
            }
        }
    }
    
    class func SendVacationApprovedEmail(email : String, date1 : NSDate, date2 : NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let fromDate = dateFormatter.stringFromDate(date1)
        let toDate = dateFormatter.stringFromDate(date2)
        
        
        let params = [
            "toEmail" : email,
            "date1" : fromDate,
            "date2" : toDate
        ]
        
        do {
            try PFCloud.callFunction("VacationApproved", withParameters: params)
        } catch {
            
        }
    }
}


















