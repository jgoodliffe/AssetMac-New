//
//  DashboardViewController.swift
//  AssetClient
//
//  Created by James Goodliffe on 15/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa
import AppKit

class DashboardViewController: NSViewController {
    
    let appDelegate = NSApp.delegate as? AppDelegate
    @IBOutlet weak var Sidepanel: NSView!
    @IBOutlet weak var titleText: NSTextField!
    @IBOutlet weak var dateText: NSTextField!
    @IBOutlet weak var welcomeText: NSTextField!
    @IBOutlet weak var btnAssets: NSButton!
    @IBOutlet weak var btnJobs: NSButton!
    @IBOutlet weak var btnLogistics: NSButton!
    @IBOutlet weak var btnMaintenance: NSButton!
    @IBOutlet weak var btnPeople: NSButton!
    
    /**
     Load all required content for the window to be useful.
     */
    func loadInitialWindowContents(){
        hideWindowContentsBeforeLoad()
        
        self.dateText.stringValue = getDate()
        let greeting = getStartOfGreeting()
        self.welcomeText.stringValue = greeting
        
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                //Animation Duration
                context.duration = 1
                
                //What is being animated:
                self.titleText.animator().alphaValue = 1
                self.dateText.animator().alphaValue = 1
                self.welcomeText.animator().alphaValue = 1
                self.btnAssets.animator().alphaValue = 1
                self.btnJobs.animator().alphaValue = 1
                self.btnLogistics.animator().alphaValue = 1
                self.btnMaintenance.animator().alphaValue = 1
                self.btnPeople.animator().alphaValue = 1
                
            }, completionHandler: {
            })
        }
    }
    
    func getStartOfGreeting() -> String{
        var greeting = String()
        let hour = Calendar.current.component(.hour, from: Date())
        
        print(hour)
        
        switch hour {
        case _ where hour < 12:
            greeting = "Good Morning, "
        case _ where hour >= 12 && hour < 17 :
            greeting = "Good Afternoon, "
        case _ where hour >= 17:
            greeting = "Good Evening, "
        default:
            print("this is impossible")
        }
        
        return greeting
    }
    
    func getDate() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        //OR dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter.string(from: date)
        return currentDateString
    }
    
    func hideWindowContentsBeforeLoad(){
        titleText.alphaValue = 0
        dateText.alphaValue = 0
        welcomeText.alphaValue = 0
        btnAssets.alphaValue = 0
        btnJobs.alphaValue = 0
        btnLogistics.alphaValue = 0
        btnMaintenance.alphaValue = 0
        btnPeople.alphaValue = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello")
        appDelegate?.enableMenuButtons()
        //hideWindowContentsBeforeLoad()
        loadInitialWindowContents()
    }
    
    @IBAction func btnAssetsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.5
              // Use the value you want to animate to (NOT the starting value)
                self.btnAssets.animator().alphaValue = 0
            }, completionHandler:{
                self.btnAssets.animator().alphaValue = 1

            })
        }
    }
}
