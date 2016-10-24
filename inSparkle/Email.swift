//
//  SendEmail.swift
//  
//
//  Created by Trever on 9/14/16.
//
//

import Foundation
import Alamofire

class Email {
    
    class func send(to: String, from: String, subject: String, body: String?, cc: String?, bcc : String?, html: String?, replyTo: String?) {
        
        let mgKey = "key-c2853cd746036f9c43ae5ba6bdbc8e7a"
        let mgDomain = "mysparklepools.com"
        
        var params : [String : AnyObject]!
        
        params = ["to" : to,
                  "from" : from,
                  "subject" : subject]
        
        if body != nil {
            params["text"] = body!
        }
        
        if cc != nil {
            params["cc"] = cc!
        }
        
        if bcc != nil {
            params["bcc"] = bcc!
        }
        
        if html != nil {
            params["html"] = html!
        }
        
        if replyTo != nil {
            params["h:Reply-To"] = replyTo!
        }
        
        print(params)
        
        Alamofire.request(.POST, "https://api.mailgun.net/v3/\(mgDomain)/messages", parameters:params)
            .authenticate(user: "api", password: mgKey)
            .response { (request, response, data, error) in
                print(request)
                print(response)
                print(error)
        }
    }
}
