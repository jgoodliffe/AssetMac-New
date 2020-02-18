//
//  AppDelegate.swift
//  AssetClient
//
//  Created by Jamie Goodliffe on 04/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit
import KPCTabsControl

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    //var dashboardViewController = DashboardViewController()
        
    @IBOutlet weak var tabMenuItem: NSMenuItem!
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var newWindow: NSMenuItem!
    @IBOutlet weak var closeWindow: NSMenuItem!

    var sb:NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
    
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
    
    func newDashboardWindow() -> NSWindow{
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "dashTab") as! DashboardViewController))
        let customToolbar = NSToolbar()
        let toolbarDelegate = MainToolbar()
        customToolbar.delegate = toolbarDelegate
        newWindow.titleVisibility = .hidden
        newWindow.styleMask.insert(.texturedBackground)
        newWindow.styleMask.insert(.fullSizeContentView)
        newWindow.titlebarAppearsTransparent = true
        newWindow.contentView?.wantsLayer = true
        newWindow.toolbar = customToolbar
        newWindow.appearance = NSAppearance(named: .darkAqua)
        return newWindow
    }
    
    func disableMainMenuButtons(){
        tabMenuItem.isEnabled = false
        closeWindow.isEnabled = false
        newWindow.isEnabled = false
        //tabMenuItem.isHidden = true
    }
    
    func enableMenuButtons(){
        //tabMenuItem.isHidden = false
        tabMenuItem.isEnabled = true
        closeWindow.isEnabled = true
        newWindow.isEnabled = true
    }
    
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
        // Connect to Server
    }

    /**
     Show the current ViewController
     */
    @IBAction func newTab(_ sender: Any) {
        let currentVC = AppDelegate.getCurrentViewController()
        //Check current Window
        if currentVC?.identifier?.rawValue=="dashboardController"{
            //Create new Tab
            let currentWindow = AppDelegate.getCurrentWindow()
            //let currentWindowCtrl = AppDelegate.getCurrentWindowController()
            let newWindow = newDashboardWindow()
            currentWindow?.addTabbedWindow(newWindow, ordered: .above)
            newWindow.makeKey()
        }
    }
    
    
    @IBAction func actionNewWindow(_ sender: Any) {
        let currentVC = AppDelegate.getCurrentViewController()
        //Check current Window
        print(currentVC?.identifier?.rawValue)
        if currentVC?.identifier?.rawValue=="dashboardController"{
            //Create new Window
            let currentWindow = AppDelegate.getCurrentWindow()
            let newWindow = newDashboardWindow()
            currentWindow?.addChildWindow(newWindow, ordered: .above)
            newWindow.makeKey()
        }
    }
    
    @IBAction func actionCloseWindow(_ sender: Any) {
        let currentVC = AppDelegate.getCurrentViewController()
        //Check current Window
        if currentVC?.identifier?.rawValue=="dashboardController"{
            //Close current Tab/Window
            currentVC?.dismiss(nil)
            let currentWindow = AppDelegate.getCurrentWindow()
            currentWindow?.close()
        }
    }
    
    
    @IBAction func showWindow(_ sender: Any) {
        for win in NSApp.windows{
            if win.isMiniaturized{
                win.deminiaturize(self)
            }
        }
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Returns the most recently presented UIViewController (visible)
    class func getCurrentViewController() -> NSViewController? {
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = NSApp.keyWindow?.contentViewController {
            var currentController: NSViewController! = rootController
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentingViewController != nil ) {
                currentController = currentController.presentingViewController
            }
            return currentController
        }
        return nil
    }
    
    // Returns the most recently presented UIViewController (visible)
    class func getCurrentWindowController() -> NSWindowController? {
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = NSApp.keyWindow?.windowController{
            return rootController
            }
        return nil
    }
    // Returns the most recently presented UIViewController (visible)
    class func getCurrentWindow() -> NSWindow? {
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = NSApp.keyWindow{
            return rootController
            }
        return nil
    }
}

