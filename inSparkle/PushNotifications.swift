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
    
    class func messagesPushNotification(sendTo : Employee) {
        let data = [
            "alert" : "New Message",
            "badge" : "Increment",
            "vc" : "messages",
            "messageID" : "1234"
        ]
        
        let installQuery = PFInstallation.query()
        installQuery?.whereKey("employee", equalTo: sendTo)
        
        let push = PFPush()
        push.setQuery(installQuery)
        push.setData(data)
        push.sendPushInBackground()
    }
    
}