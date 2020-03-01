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
    
    func createNewTab(window:NSWindow){
        let currentVC = AppDelegate.getCurrentViewController()
        //Check current Window
        if currentVC?.identifier?.rawValue=="dashboardController"{
            //Create new Tab
            let currentWindow = AppDelegate.getCurrentWindow()
            //let currentWindowCtrl = AppDelegate.getCurrentWindowController()
            let newWindow = window
            currentWindow?.addTabbedWindow(newWindow, ordered: .above)
            newWindow.makeKeyAndOrderFront(currentWindow)
        }
    }
    
    func showDashboard(){
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
        createNewTab(window: newWindow)
    }
    
    func showLogistics(){
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "logisticsTab") as! LogisticsViewController))
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
        createNewTab(window: newWindow)
    }
    
    func showMaintenance(){
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "maintenanceTab") as! MaintenanceViewController))
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
        createNewTab(window: newWindow)
    }
    
    func showJobs(){
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "jobsTab") as! JobsViewController))
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
        createNewTab(window: newWindow)
    }
    
    func showAssets(){
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "assetsTab") as! AssetsViewController))
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
        createNewTab(window: newWindow)
    }
    
    func showPeople(){
        let newWindow = NSWindow(contentViewController: (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "peopleTab") as! PeopleViewController))
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
        createNewTab(window: newWindow)
    }
}
