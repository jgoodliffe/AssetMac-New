//
//  Authentication.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 04/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class Authentication: NSObject {
    
    //typealias CompletionHandler = (success:Bool) -> Void

    let port: Int = 50000
    let host: String = ""
    let username: String = ""
    let password: String = ""
    
    func login(hostName: String,username: String, password:String, completion: (_ result: Bool) -> Void) {
        //sleep(5)
        
        let hostAddress:NSURL = NSURL(fileURLWithPath: hostName + ":" + String(port) + "/login/")

        completion(true)
    }
    
}
