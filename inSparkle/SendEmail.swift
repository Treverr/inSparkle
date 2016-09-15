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
    
    let mgKey = "key-c2853cd746036f9c43ae5ba6bdbc8e7a"
    let mgDomain = "mysparklepools.com"
    
    func send(params : [String : AnyObject]) {
        
        Alamofire.request(.POST, "https://api.mailgun.net/v3/\(mgDomain)/messages", parameters:params)
            .authenticate(user: "api", password: mgKey)
            .response { (request, response, data, error) in
                print(request)
                print(response)
                print(error)
        }
        
    }
}
