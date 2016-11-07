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
    
    class func AddUpdateCustomerRecord(_ accountNumber : String?, name : String, address : String, phoneNumber : String) {
        
        let to = "robert@mysparklepools.com"
        let from = "inSparkle App Team <trever@insparklepools.com>"
        let subject = "Customer Add / Update"
        
        if accountNumber != nil {
            
            let body = "The following customer needs added or updated: \n\n Customer Account Number: \(accountNumber!)\n Customer Name: \(name)\n Customer Address: \(address)\n Customer Phone Number: \(phoneNumber)\n\n Thank you,\n\n The inSparkle App Team\n\n\n\n*** This is an automatically generated email, please do not reply ***"
            
            Email.send(to, from: from, subject: subject, body: body, cc: nil, bcc: nil, html: nil, replyTo: nil)
            
        } else {
            
            let body = "The following customer needs added or updated: \n\n Customer Account Number:\n Customer Name: \(name)\n Customer Address: \(address)\n Customer Phone Number: \(phoneNumber)\n\n Thank you,\n\n The inSparkle App Team\n\n\n\n*** This is an automatically generated email, please do not reply ***"
            
            Email.send(to, from: from, subject: subject, body: body, cc: nil, bcc: nil, html: nil, replyTo: nil)
        }
    }
    
    class func AlertOfCancelation(_ name : String, address : String, phone : String, reason : String, cancelBy : String, theDates : String, theType : String) {
        
        let to = "robert@mysparklepools.com"
        let from = "inSparkle App Team <trever@insparklepools.com>"
        let subject = "Cancelled Pool Opening / Closing"
        
        let body = "The following customer has canceled their appointment: " +
            "\n\n Customer Name: " + name +
            "\n Customer Address: " + address +
            "\n Customer Phone Number: " + phone +
            "\n Date: " + theDates +
            "\n Open / Close: " + theType +
            "\n Cancelation Reason: " + reason +
            "\n\n Canceled By: " + cancelBy +
            "\n\n Thank you," +
            "\n\n The inSparkle App Team" +
            "\n\n" +
            "\n\n" +
        "*** This is an automatically generated email, please do not reply ***"
        
        Email.send(to, from: from, subject: subject, body: body, cc: nil, bcc: nil, html: nil, replyTo: nil)
        
    }
    
    class func UpdateUserAdminStatus(_ username : String, adminStatus : Bool, alert : UIAlertController, completion : (_ complete : Bool) -> Void) {
        let parameters = [
            "username" : username,
            "adminStatus" : adminStatus,
            ] as [String : Any]
        
        PFCloud.callFunction(inBackground: "modifyAdminStatus", withParameters: parameters) { (reponse, error) in
            if error == nil {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        completion(true)
    }
    
    class func UpdateUserInfo(_ username : String, email : String, objectId : String, completion : @escaping (_ isComplete : Bool) -> Void) {
        let params = [
            "username" : username,
            "emailAddy" : email,
            "objId" : objectId
        ]
        
        PFCloud.callFunction(inBackground: "updateUserInformation", withParameters: params) { (response, error) in
            if error == nil {
                completion(true)
            }
        }

    }
    
    class func UpdateUserSpecialAccess(_ objId : String, specialAccesses : NSArray, completion : @escaping (_ isComplete : Bool) -> Void) {
        let params = [
            "objId" : objId,
            "specAccess" : specialAccesses,
            ] as [String : Any]
        
        PFCloud.callFunction(inBackground: "UpdateUserSpecialAccess", withParameters: params) { (response, error) in
            if error == nil {
                completion(true)
            }
        }

    }
    
    class func CreateNewUser(_ username : String, password : String, emailAddy : String, adminStatus : Bool, empID : String, completion : @escaping (_ isComplete : Bool, _ objectID : String) -> Void) {
        
        let params = [
            "username" : username,
            "password" : password,
            "emailAddy" : emailAddy,
            "adminStatus" : adminStatus,
            "empID" : empID,
            "enabled" : true
            ] as [String : Any]
        
        do {
            PFCloud.callFunction(inBackground: "CreateNewUser", withParameters: params, block: { (response, error) in
                if error == nil {
                    completion(true, response as! String)
                }
            })
            
        }
    }
    
    class func DisableEnableUser (_ userObjID : String, enabled : Bool, completion : @escaping (_ complete : Bool) -> Void) {
        let params = [
            "objId" : userObjID,
            "enabled" : enabled
        ] as [String : Any]
        
        do {
            
            PFCloud.callFunction(inBackground: "UpdateUserStatus", withParameters: params, block: { (response, error) in
                if error == nil {
                    completion(true)
                }
            })
        }
    }
    
    class func ChangeUserPassword(_ username : String, newPassword : String, completion: @escaping (_ isComplete : Bool) -> Void) {
        let params = [
            "username" : username,
            "newPassword" : newPassword
        ]
        
        PFCloud.callFunction(inBackground: "changeUserPassword", withParameters: params) { (result, error) in
            if (error == nil) {
                completion(true)
            }
        }
    }
    
    class func SendVacationApprovedEmail(_ email : String, date1 : Date, date2 : Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: UserDefaults.standard.integer(forKey: "SparkleTimeZone"))
        let fromDate = dateFormatter.string(from: date1)
        let toDate = dateFormatter.string(from: date2)
        
        do {
            let pathToHTML = Bundle.main.path(forResource: "VacationApprovedHTML", ofType: "html")
            
            var HTMLContent = try String(contentsOfFile: pathToHTML!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#date1", with: fromDate)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#date2", with: toDate)
            
            Email.send(email, from: "Sparkle HR <sparklepools@insparklepools.com>", subject: "Your vacation request is approved.", body: nil, cc: nil, bcc: "trever@insparklepools.com", html: HTMLContent, replyTo: "Time Away Requests <timeawayrequests@mysparklepools.com>")
            
        } catch {
            print(error)
        }
    }
    
    //    class func SendReturnTimeAway(email : String, date1: NSDate, date2 : NSDate, type: String) {
    //        let dateFormatter = NSDateFormatter()
    //        dateFormatter.dateFormat = "dd-MMM-yyyy"
    //        let fromDate = dateFormatter.stringFromDate(date1)
    //        let toDate = dateFormatter.stringFromDate(date2)
    //
    //        let params = [
    //            "email" : email,
    //            "date1" : fromDate,
    //            "date2" : toDate,
    //            "type" : type
    //        ]
    //
    //        PFCloud.callFunctionInBackground("VacationReturned", withParameters: params) { (result, error) in
    //            if error == nil {
    //                print(error)
    //            }
    //        }
    //    }
    //
    //    class func SendUnpaidTimeAwayApprovedEmail(email : String, dates : String) {
    //        let dateFormatter = NSDateFormatter()
    //        dateFormatter.dateFormat = "dd-MMM-yyyy"
    //
    //        let params = [
    //            "email" : email,
    //            "dates" : dates,
    //            "type" : "Unpaid Time Away"
    //        ]
    //
    //        PFCloud.callFunctionInBackground("UnpaidTimeAwayApproved", withParameters: params) { (result, error) in
    //            if error == nil {
    //
    //            }
    //        }
    //    }
    
    //    class func SendNotificationOfNewTimeAwayRequest(requestFor : String, type : String, date1 : NSDate, date2 : NSDate, totalHours : Double) {
    //        let dateFormatter = NSDateFormatter()
    //        dateFormatter.dateFormat = "dd-MMM-yyyy"
    //
    //        let pDate1 = dateFormatter.stringFromDate(date1)
    //        let pDate2 = dateFormatter.stringFromDate(date2)
    //
    //        let params = [
    //            "requestFor" : requestFor,
    //            "type" : type,
    //            "date1" : pDate1,
    //            "date2" : pDate2,
    //            "totalHours" : String(totalHours)
    //        ]
    //
    //        PFCloud.callFunctionInBackground("SendNewTimeAwayEmail", withParameters: params) { (result, error) in
    //            if error == nil {
    //
    //            }
    //        }
    //    }
    
    //    class func SendWelcomeEmail(name : String, toEmail : String, emailAddress : String) {
    //
    //        let params = [
    //            "toEmail" : toEmail,
    //            "name" : name,
    //            "emailAddy" : emailAddress
    //        ]
    //
    //        PFCloud.callFunctionInBackground("SendWelcomeEmail", withParameters: params) { (result, error) in
    //            if error == nil {
    //
    //            }
    //        }
    //    }
    //
    //    class func TimeAwayCancelEmail(employeeName : String, type : String, date1 : NSDate, date2 : NSDate, totalHours: Double) {
    //        let dateFormatter = NSDateFormatter()
    //        dateFormatter.dateFormat = "dd-MMM-yyyy"
    //
    //        let dateOne = dateFormatter.stringFromDate(date1)
    //        let dateTwo = dateFormatter.stringFromDate(date2)
    //
    //        let params = [
    //            "employeeName" : employeeName,
    //            "type" : type,
    //            "date1" : dateOne,
    //            "date2" : dateTwo,
    //            "totalHours" : String(totalHours)
    //        ]
    //
    //        PFCloud.callFunctionInBackground("TimeAwayCancelEmail", withParameters: params) { (result, error) in
    //            if error == nil {
    //
    //            }
    //        }
    //    }
}
