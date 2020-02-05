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

    let port: Int = 50000
    let host: String = ""
    let username: String = ""
    let password: String = ""
    
    func login(host: String, username: String, password: String) -> Bool {
        return false
    }
    
}
