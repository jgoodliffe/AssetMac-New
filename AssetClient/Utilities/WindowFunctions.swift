//
//  WindowFunctions.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//
//  handles all window change stuff.
//

import Foundation
import AppKit
import Cocoa

class WindowFunctions{
    let appDelegate = NSApp.delegate as? AppDelegate
    var masterVC: MasterViewController
    var currentView: NSViewController
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    init(masterVC: NSViewController, currentView: NSViewController){
        self.masterVC = masterVC as! MasterViewController
        self.currentView = currentView
    }
    
    func createNewTab(window:NSWindow){
        let currentVC = AppDelegate.getCurrentViewController()
        //Check current Window
        //Create new Tab
        let currentWindow = AppDelegate.getCurrentWindowController()?.window
        let newWindow = window
        currentWindow?.addTabbedWindow(newWindow, ordered: .above)
        newWindow.makeKeyAndOrderFront(currentWindow)
    }
    
    func removeChildVC(asChildViewController viewController: NSViewController){
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func showDashboard(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "dashTab") as! DashboardViewController)
        newWC.UsersToolbarItem()
        createNewTab(window: newWC.window!)
//        removeChildVC(asChildViewController: currentView)
    }
    
    func showLogistics(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "logisticsTab") as! LogisticsViewController)
        createNewTab(window: newWC.window!)
    }
    
    func showMaintenance(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "maintenanceTab") as! MaintenanceViewController)
        createNewTab(window: newWC.window!)
    }
    
    func showJobs(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "jobsTab") as! JobsViewController)
        createNewTab(window: newWC.window!)
    }
    
    func showAssets(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "assetsTab") as! AssetsViewController)
        createNewTab(window: newWC.window!)
    }
    
    func showPeople(){
        let newWC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "masterWindowController") as! MasterWindowController
        newWC.contentViewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "peopleTab") as! PeopleViewController)
        createNewTab(window: newWC.window!)
    }
}
