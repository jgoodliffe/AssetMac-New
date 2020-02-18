//
//  DashboardWindowController.swift
//  AssetClient
//
//  Created by James Goodliffe on 15/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit

extension Notification.Name {
    static let changePasswordPressed = Notification.Name("changePassword")
    //static let rowDeselected = Notification.Name("turnOff")
}

class DashboardWindowController: NSWindowController, NSToolbarDelegate {
    
    let appDelegate = NSApp.delegate as? AppDelegate
    
    override func windowDidLoad() {
        super.windowDidLoad()

        appDelegate?.enableMenuButtons()
        
        //let addPerson = NSToolbarItem()
        //addPerson.label = "Add Person"
        let mainToolbar = NSToolbar(identifier: "mainToolbar")
        let mainToolbarDelegate = MainToolbar()
        mainToolbar.delegate = mainToolbarDelegate
        window?.titleVisibility = .hidden
        window?.styleMask.insert(.texturedBackground)
        window?.styleMask.insert(.fullSizeContentView)
        window?.titlebarAppearsTransparent = true
        window?.contentView?.wantsLayer = true
        window?.toolbar = mainToolbar
        
        for item in mainToolbar.items{
            switch item.itemIdentifier.rawValue{
            case "BackToolbarItem":
                item.action = #selector(BackToolbarItem)
            case "AddToolbarItem":
                item.action = #selector(AddToolbarItem)
            case "DashboardToolbarItem":
                item.action = #selector(DashboardToolbarItem)
            case "InventoryToolbarItem":
                item.action = #selector(InventoryToolbarItem)
            case "CalendarToolbarItem":
                item.action = #selector(CalendarToolbarItem)
            case "UsersToolbarItem":
                item.action = #selector(UsersToolbarItem)
            case "PasswordResetToolbarItem":
                item.action = #selector(PasswordResetToolbarItem)
            case "LogoutToolbarItem":
                item.action = #selector(LogoutToolbarItem)
            case "SettingsToolbarItem":
                item.action = #selector(SettingsToolbarItem)
            default:
                item.action = #selector(toolbarAction)
            }
        }
    }
    
    @objc func toolbarAction(){
        print("Defualt")
    }
    
    @objc func BackToolbarItem(){
        //print("received1")
        
    }
    
    @objc func AddToolbarItem(){
        //print("received2")
    }
    
    @objc func DashboardToolbarItem(){
        //print("received3")
    }
    
    @objc func InventoryToolbarItem(){
        //print("received4")
    }
    
    @objc func CalendarToolbarItem(){
        //print("received5")
    }
    
    @objc func UsersToolbarItem(){
        //print("received6")
    }
    
    @objc func PasswordResetToolbarItem(){
        NotificationCenter.default.post(Notification(name: .changePasswordPressed))
    }
    
    @objc func LogoutToolbarItem(){
        //print("received8")
    }
    
    @objc func SettingsToolbarItem(){
        //print("received9")
    }
    
    init(window: NSWindow){
        super.init(window: window)
        shouldCascadeWindows = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }
}
