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
private var hostnameStore:[NSManagedObject] = []


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
    
    
    //TODO: Get a string list of hostnames from the CoreData object...
    func retrieveAllHostnames() -> [String]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HostStore")
        var allHostnames:[String] = []
        do{
            hostnameStore = try context.fetch(request) as! [NSManagedObject]
            if let hostnames = hostnameStore as? [HostStore] {
                for entry in hostnames{
                    allHostnames.append(entry.hostname)
                }
                return allHostnames
            }
        } catch{
            debugPrint("Failed to pull CoreData")
            return []
        }
        return []
    }
    
    func storeHostname(newHostName: String){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HostStore")
        let hostStoreIdentity = NSEntityDescription.entity(forEntityName: "HostStore",  in: context)
        let new = NSManagedObject(entity: hostStoreIdentity!, insertInto: context)
        new.setValue(newHostName, forKey: "hostname")
        do{
            try context.save()
        } catch{
            debugPrint("Failed to save hostname.")
        }
    }
    
    func clearHostnames(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HostStore")
        do{
            hostnameStore = try context.fetch(request) as! [NSManagedObject]
            if hostnameStore.count>0{
                for object in hostnameStore{
                    context.delete(object) //Remove all invalid tokens.
                    try context.save()
                }
            }
        } catch{
            debugPrint("Failed to pull CoreData")
        }

    }
}
