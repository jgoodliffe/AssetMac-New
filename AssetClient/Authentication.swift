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

    let port: Int = 8080
    let host: String = ""
    let username: String = ""
    let password: String = ""
    
    func login(hostName: String,username: String, password:String, completion: (_ result: Bool) -> Void) {
        //sleep(5)
        
        let hostAddress:String = hostName + ":" + String(port) + "/login/"
        let parameters: Parameters = ["username":username, "password":password]
        
        let authString: String = username + ":" + password
        //print(authString)
        let authStringUTF8 = authString.data(using: .utf8) //Encode to UTF-8
        //print(authStringUTF8)
        
        
        let authStringB64 = authStringUTF8?.base64EncodedString()
        print(authStringB64)
        
        //TODO: >Unwrap optional value
        //      >Send as POST
        //      >Set up SSL

        
        //Post Request for login.
        AF.request(hostAddress,method: .post, parameters: parameters).responseJSON { response in
            switch response.result{
            case.success:
                let json = JSON(response.data)
                print(json)
                
            case.failure(let error):
                print("Error occurred while trying to login.")
                print(error)
                
            }
        }

        completion(true)
    }
    
}
