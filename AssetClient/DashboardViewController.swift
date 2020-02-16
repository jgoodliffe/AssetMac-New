//
//  DashboardViewController.swift
//  AssetClient
//
//  Created by James Goodliffe on 15/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class DashboardViewController: NSViewController {
    
    let appDelegate = NSApp.delegate as? AppDelegate
    @IBOutlet weak var Sidepanel: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        appDelegate?.enableMenuButtons()
        view.window?.isOpaque = false
        //view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.systemGray.cgColor
    }
    
}
