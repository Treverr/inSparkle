//
//  CloudCode.swift
//  inSparkle
//
//  Created by Trever on 12/13/15.
//  Copyright © 2015 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse
import Alamofire

class CloudCode {
    
    class func AddUpdateCustomerRecord(accountNumber : String?, name : String, address : String, phoneNumber : String) {
        
        if accountNumber != nil {
            
            let body = "The following customer needs added or updated: \n\n Customer Account Number: \(accountNumber!)\n Customer Name: \(name)\n Customer Address: \(address)\n Customer Phone Number: \(phoneNumber)\n\n Thank you,\n\n The inSparkle App Team\n\n\n\n*** This is an automatically generated email, please do not reply ***"
            
            let parameters = [
                "to" : "robert@mysparklepools.com",
                "from" : "inSparkle App Team <inSparkleApp@mysparklepools.com>",
                "subject" : "Customer Update / Addition",
                "text" : body
            ]
            
            Email().send(parameters)
            
        } else {
            
            let body = "The following customer needs added or updated: \n\n Customer Account Number:\n Customer Name: \(name)\n Customer Address: \(address)\n Customer Phone Number: \(phoneNumber)\n\n Thank you,\n\n The inSparkle App Team\n\n\n\n*** This is an automatically generated email, please do not reply ***"
            
            let parameters = [
                "to" : "robert@mysparklepools.com",
                "from" : "inSparkle App Team <inSparkleApp@mysparklepools.com>",
                "subject" : "Customer Update / Addition",
                "text" : body
            ]
            
            Email().send(parameters)
        }
    }
    
    class func AlertOfCancelation(name : String, address : String, phone : String, reason : String, cancelBy : String, theDates : String, theType : String) {
        
        let params = [
            "cxname" : name,
            "FullAddress" : address,
            "cxPhoneNumber" : phone,
            "cancelationReason" : reason,
            "whoCancel" : cancelBy,
            "theDates" : theDates,
            "theType" : theType,
            ]
        
        PFCloud.callFunctionInBackground("AlertOfCancelation", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
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
            "enabled" : true
            ]
        
        do {
            PFCloud.callFunctionInBackground("CreateNewUser", withParameters: params as [NSObject : AnyObject], block: { (response : AnyObject?, error : NSError?) in
                if error == nil {
                    completion(isComplete: true, objectID: response as! String)
                }
            })
        }
    }
    
    class func DisableEnableUser (userObjID : String, enabled : Bool, completion : (complete : Bool) -> Void) {
        let params = [
            "objId" : userObjID,
            "enabled" : enabled
        ]
        
        do {
            PFCloud.callFunctionInBackground("UpdateUserStatus", withParameters: params as [NSObject : AnyObject], block: { (response : AnyObject?, error : NSError?) in
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
            "email" : email,
            "date1" : fromDate,
            "date2" : toDate
        ]
        
        PFCloud.callFunctionInBackground("VacationApproved", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
    }
    
    class func SendReturnTimeAway(email : String, date1: NSDate, date2 : NSDate, type: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let fromDate = dateFormatter.stringFromDate(date1)
        let toDate = dateFormatter.stringFromDate(date2)
        
        let params = [
            "email" : email,
            "date1" : fromDate,
            "date2" : toDate,
            "type" : type
        ]
        
        PFCloud.callFunctionInBackground("VacationReturned", withParameters: params) { (result, error) in
            if error == nil {
                print(error)
            }
        }
    }
    
    class func SendUnpaidTimeAwayApprovedEmail(email : String, dates : String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        let params = [
            "email" : email,
            "dates" : dates,
            "type" : "Unpaid Time Away"
        ]
        
        PFCloud.callFunctionInBackground("UnpaidTimeAwayApproved", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
    }
    
    class func SendNotificationOfNewTimeAwayRequest(requestFor : String, type : String, date1 : NSDate, date2 : NSDate, totalHours : Double) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        let pDate1 = dateFormatter.stringFromDate(date1)
        let pDate2 = dateFormatter.stringFromDate(date2)
        
        let params = [
            "requestFor" : requestFor,
            "type" : type,
            "date1" : pDate1,
            "date2" : pDate2,
            "totalHours" : String(totalHours)
        ]
        
        PFCloud.callFunctionInBackground("SendNewTimeAwayEmail", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
    }
    
    class func SendWelcomeEmail(name : String, toEmail : String, emailAddress : String) {
        
        let params = [
            "toEmail" : toEmail,
            "name" : name,
            "emailAddy" : emailAddress
        ]
        
        PFCloud.callFunctionInBackground("SendWelcomeEmail", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
    }
    
    class func TimeAwayCancelEmail(employeeName : String, type : String, date1 : NSDate, date2 : NSDate, totalHours: Double) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        let dateOne = dateFormatter.stringFromDate(date1)
        let dateTwo = dateFormatter.stringFromDate(date2)
        
        let params = [
            "employeeName" : employeeName,
            "type" : type,
            "date1" : dateOne,
            "date2" : dateTwo,
            "totalHours" : String(totalHours)
        ]
        
        PFCloud.callFunctionInBackground("TimeAwayCancelEmail", withParameters: params) { (result, error) in
            if error == nil {
                
            }
        }
    }
}






































