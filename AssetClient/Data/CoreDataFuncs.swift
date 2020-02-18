//
//  CoreDataFuncs.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 18/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Foundation
import CoreData
import AppKit

//Token Stores + App Delegate Declaration
let appDelegate = NSApp.delegate as? AppDelegate
private let context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
private var tokenStore:[NSManagedObject] = []

//Alamofire Information
let port: String = "8080"

/**
 Gets the most recent authentication token and host from CoreData.
 */
class CoreDataFuncs{
    func retrieveTokenAndHost()-> [String]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AuthStore")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        do{
            tokenStore = try context.fetch(request) as! [NSManagedObject]
            if let tokens = tokenStore as? [AuthStore] {
                //Get first array item
                if let token = tokens.first {
                    let requestToken = token.token ?? "invalidTokenRequest" //0
                    let host = token.host ?? "http://localhost" //1
                    let userID = token.userID ?? "0" //2
                    return [requestToken, host, userID]
                }
            }
        } catch{
            debugPrint("Failed to pull CoreData")
            return []
        }
        return []
    }
}
