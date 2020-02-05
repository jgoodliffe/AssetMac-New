//
//  JSONFunctions.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 04/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class JSONFunctions: NSObject {
    
    func getJSONObject(){
        let url = "http://localhost:8080/person/all"
        let parameters: Parameters = [:]
        AF.request(url).responseJSON { response in
            switch response.result{
            case.success:
                let json = JSON(response.data)
                
                //Grab a Key
                let jarr:JSON = json["people"]
                
                
                //Iterate through JSON Array
                for(_, object) in jarr{
                    let name = object["firstname"].stringValue
                    print(name)
                }
                
            case.failure(let error):
                print("An error occurred! \n")
            }
        }
    }
}
