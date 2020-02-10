//
//  AppDelegate.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 04/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AssetClient")
        container.loadPersistentStores(completionHandler: {
            (description, error) in
            debugPrint(description)
            if let error = error as NSError? {
                fatalError("Unresolved Error.")
            }
        })
        return container
    }()
    
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("error")
            }
        }
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

