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
    
    class func AlertOfCancelation(name : String, address : String, phone : String, reason : String, cancelBy : String) {
        do {
            try PFCloud.callFunction("AlertOfCancelation", withParameters: [
                "cxname" : name,
                "FullAddress" : address,
                "cxPhoneNumber" : phone,
                "cancelationReason" : reason,
                "whoCancel" : cancelBy
                ])
        } catch { }
        
    }
    
}
