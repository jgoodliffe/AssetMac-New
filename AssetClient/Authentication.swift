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
    var manager = Alamofire.Session.default
    let configuration = URLSessionConfiguration.default

    
    
    func login(hostName: String,username: String, password:String, success: @escaping (_ response: Bool) -> Void, failure: @escaping (_ error: String) -> Void) {
        //sleep(5)
        
        
        //manager.session.configuration.timeoutIntervalForRequest = 5
        //manager.session.configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        self.manager = Alamofire.Session(configuration:configuration)
    
        let hostAddress:String = hostName + ":" + String(port) + "/login/"
        let parameters: Parameters = ["username":username, "password":password]
        
        let authString: String = username + ":" + password
        //print(authString)
        let authStringUTF8 = authString.data(using: .utf8) //Encode to UTF-8
        //print(authStringUTF8)
        
        
        let authStringB64 = authStringUTF8?.base64EncodedString()
        print(authStringB64)
        
        let headers: HTTPHeaders = [
            "auth": authStringB64 ?? ""]
        
        //TODO: >Unwrap optional value
        //      >Send as POST
        //      >Set up SSL

        
        //Post Request for login.
        manager.request(hostAddress,method: .post, parameters: parameters, headers: headers).responseJSON { response in
            //Attempt to decode response
            switch response.result{
            
                ///Successfully decoded JSON
                case.success(let jsonResponse):
                    //Map response into Array and check response code.
                    if let JSON = jsonResponse as? [String:Any]{
                        let status = JSON["response-code"] as! Int
                        debugPrint("Response code: "+String(status))
                        
                        if(status==200){
                            success(true)
                            print(JSON)
                        } else{
                            let errorMessage:String = "Error Logging In.\n Error Code: "+String(status)+" "+String(JSON["error-type"] as! String)
                            failure(errorMessage)
                        }
                    } else{
                        failure("Unable to parse response. No Error code was found.")
                    }
                    
                ///Failed to decode JSON
                case.failure(let error):
                    ///Deciper error before returning.
                    let errorCode:Int = error.responseCode ?? 0
                    let errorMessage:String = error.localizedDescription
                    debugPrint("========Error=======")
                    debugPrint(errorCode)
                    debugPrint(errorMessage)
                    
                    
                    if let data = response.data, let str = String(data: data, encoding: .utf8){
                        debugPrint("Server Error: "+str)
                        failure("Invalid response received from server. Check log for more details.")
                    }
                    
                    if let data = response.data, let code = Int?(response.response?.statusCode ?? 0){
                        debugPrint("Response Status Code: "+String(code))
                        failure("Invalid response received from server. Check log for more details.")
                    }
                    
                    failure(errorMessage)
            }
        }

        //completion(true)
    }
    
}
