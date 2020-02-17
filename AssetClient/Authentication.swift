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
import AppKit
import CoreData

class Authentication: NSObject {
    
    //typealias CompletionHandler = (success:Bool) -> Void

    let port: Int = 8080
    let host: String = ""
    let username: String = ""
    let password: String = ""
    var manager = Alamofire.Session.default
    let configuration = URLSessionConfiguration.default
    
    
    private let appDelegate = NSApp.delegate as! AppDelegate
    private let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    private var tokenStore:[NSManagedObject] = []
    
    //private var tokenStore:NSManagedObject = [Auth]
    
    func resetPassword(hostName: String, username: String, success: @escaping (_ response: Bool)-> Void, failure: @escaping (_ error: String) -> Void){
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        self.manager = Alamofire.Session(configuration:configuration)
        
        let hostAddress:String = hostName + ":" + String(port) + "/login/"
        let parameters:Parameters = ["loginType":"changePassword"]
        
        let authString: String = username
        let authStringUTF8 = authString.data(using: .utf8) //Encode to UTF-8
        let authStringB64 = authStringUTF8?.base64EncodedString()
        let headers: HTTPHeaders = [
            "auth": authStringB64 ?? "" ]
        
        
        manager.request(hostAddress, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            switch response.result{
            case.success(let jsonResponse):
                if let JSON = jsonResponse as? [String:Any]{
                    let status = JSON["response-code"] as! Int
                    debugPrint("Response code: "+String(status))
                    if(status==200){
                        success(true)
                    } else{
                        let errorMessage:String = "Error Logging In.\n Error Code: "+String(status)+" "+String(JSON["error-type"] as! String)
                        failure(errorMessage)
                    }
            }
            case.failure(let error):
                let errorCode:Int = error.responseCode ?? 0
                let errorMessage:String = error.localizedDescription
                failure(errorMessage)
            }
        }
    }
    
    
    func login(hostName: String,username: String, password:String, success: @escaping (_ response: Bool) -> Void, failure: @escaping (_ error: String) -> Void) {
        configuration.timeoutIntervalForResource = 5
        configuration.timeoutIntervalForRequest = 5
        
        //Attempt to get Token Store
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthStore")
        do{
            tokenStore = try context.fetch(request) as! [NSManagedObject]
            debugPrint("TokenStore Count: "+String(tokenStore.count))
            if tokenStore.count>0{
                for object in tokenStore{
                    context.delete(object) //Remove all invalid tokens.
                    try context.save()
                }
            }
        } catch{
            debugPrint("Failed to pull CoreData")
        }

        
        self.manager = Alamofire.Session(configuration:configuration)
            
        let hostAddress:String = hostName + ":" + String(port) + "/login/"
        let parameters: Parameters = ["loginType":"login"]
        
        let authString: String = username + ":" + password
        let authStringUTF8 = authString.data(using: .utf8) //Encode to UTF-8
        let authStringB64 = authStringUTF8?.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "auth": authStringB64 ?? ""]
        
        //TODO: >Unwrap optional value
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
                            
                            let token = JSON["auth-token"]
                            let userLevel = JSON["user-level"]
                            
                            debugPrint("Received Token! " + (token as! String))
                            let authStoreEntity = NSEntityDescription.entity(forEntityName: "AuthStore",  in: self.context)
                
                            //Store received authentication token.
                            let newToken = NSManagedObject(entity: authStoreEntity!, insertInto: self.context)
                            newToken.setValue(username, forKey: "username")
                            newToken.setValue(token, forKey: "token")
                            newToken.setValue(userLevel, forKey: "userLevel")
                            newToken.setValue(hostName, forKey: "host")
                            newToken.setValue(NSDate(), forKey: "date")

                            do{
                                try self.context.save()
                                success(true)
                            } catch{
                                debugPrint("Failed to save token.")
                                failure("Unable to Save Authentication Token.")
                            }
                            
    
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
