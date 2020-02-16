//
//  DashboardWindowController.swift
//  AssetClient
//
//  Created by James Goodliffe on 15/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit

class DashboardWindowController: NSWindowController {

    let appDelegate = NSApp.delegate as? AppDelegate

    override func windowDidLoad() {
        super.windowDidLoad()

        appDelegate?.enableMenuButtons()
        
        //let addPerson = NSToolbarItem()
        //addPerson.label = "Add Person"
        //addPerson.image = NSImage.init(byReferencing: <#T##URL#>)
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.styleMask.insert(.texturedBackground)
        window?.styleMask.insert(.fullSizeContentView)
        window?.titlebarAppearsTransparent = true
        window?.contentView?.wantsLayer = true
        window?.toolbar = customToolbar
        //window?.styleMask.remove(.titled)
        //window?.isMovableByWindowBackground = true
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
