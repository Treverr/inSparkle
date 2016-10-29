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
    
    class func send(_ to: String, from: String, subject: String, body: String?, cc: String?, bcc : String?, html: String?, replyTo: String?) {
        
        let mgKey = "key-c2853cd746036f9c43ae5ba6bdbc8e7a"
        let mgDomain = "mysparklepools.com"
        
        var params : [String : AnyObject]!
        
        params = ["to" : to as AnyObject,
                  "from" : from as AnyObject,
                  "subject" : subject as AnyObject]
        
        if body != nil {
            params["text"] = body! as AnyObject?
        }
        
        if cc != nil {
            params["cc"] = cc! as AnyObject?
        }
        
        if bcc != nil {
            params["bcc"] = bcc! as AnyObject?
        }
        
        if html != nil {
            params["html"] = html! as AnyObject?
        }
        
        if replyTo != nil {
            params["h:Reply-To"] = replyTo! as AnyObject?
        }
        
        print(params)

        let url = "https://api.mailgun.net/v3/\(mgDomain)/messages"
        Alamofire.request(url, method: .post, parameters: params)
            .authenticate(user: "api", password: mgKey)
            .response { response in
                print(response)
                print(response.request)
                print(response.error)
        }
    }
}
