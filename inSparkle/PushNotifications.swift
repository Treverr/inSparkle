//
//  PushNotifications.swift
//  inSparkle
//
//  Created by Trever on 1/13/16.
//  Copyright © 2016 Sparkle Pools. All rights reserved.
//

import Foundation
import Parse

class PushNotifications {
    
    class func messagesPushNotification(_ sendTo : Employee) {
        
        let sendToID = sendTo.objectId!
        
        let data = [
            "sendToUser" : sendToID
        ]
        
        PFCloud.callFunction(inBackground: "sendMessageNotification", withParameters: data) { (result, error) in
            if error != nil {
                
                let alert = UIAlertController(title: "Error", message: "There was an error sending the notification.", preferredStyle: .alert)
                let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
                
                UIApplication.shared.keyWindow?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
}
