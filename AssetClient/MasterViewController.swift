//
//  MasterViewController.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 04/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

extension Notification.Name{
    static let dashboardTab = Notification.Name("dashboardTab")
    static let assetsTab = Notification.Name("assetsTab")
    static let logisticsTab = Notification.Name("logisticsTab")
    static let jobsTab = Notification.Name("jobsTab")
    static let maintenanceTab = Notification.Name("maintenanceTab")
    static let peopleTab = Notification.Name("peopleTab")
}

class MasterViewController: NSViewController {
    
    var dashboard: DashboardViewController! //1
    var assets: AssetsViewController! //2
    var jobs: JobsViewController! //3
    var maintenance: MaintenanceViewController! //4
    var logistics: LogisticsViewController! //5
    var people: PeopleViewController! //6
    

    @IBOutlet var container: NSView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container.autoresizesSubviews = true
        
        dashboard = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "dashTab") as! DashboardViewController
        assets = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "assetsTab") as! AssetsViewController
        logistics = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "logisticsTab") as! LogisticsViewController
        jobs = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "jobsTab") as! JobsViewController
        maintenance = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "maintenanceTab") as! MaintenanceViewController
        people = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "peopleTab") as! PeopleViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.callPasswordChangeSegue(_:)), name: .changePasswordPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeWindow(_:)), name: .changedUserPassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logOut(_:)), name: .logOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.jobsTab(_:)), name: .jobsTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.maintenanceTab(_:)), name: .maintenanceTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.peopleTab(_:)), name: .peopleTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logisticsTab(_:)), name: .logisticsTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.assetsTab(_:)), name: .assetsTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dashboardTab(_:)), name: .dashboardTab, object: nil)
    }
    
    @objc func jobsTab(_ notification: Notification)->Void{
        switchViews(viewID: 4)
    }
    @objc func assetsTab(_ notification: Notification)->Void{
        switchViews(viewID: 2)
    }
    @objc func dashboardTab(_ notification: Notification)->Void{
        switchViews(viewID: 1)
    }
    @objc func maintenanceTab(_ notification: Notification)->Void{
        switchViews(viewID: 5)
    }
    @objc func peopleTab(_ notification: Notification)->Void{
        switchViews(viewID: 6)
    }
    @objc func logisticsTab(_ notification: Notification)->Void{
        switchViews(viewID: 3)
    }
    
    @objc func callPasswordChangeSegue(_ notification: Notification){
        //Only open Dialogue if window is key (active)!
        if(view.window==NSApplication.shared.keyWindow){
            performSegue(withIdentifier: "showChangePassword", sender: notification)
        }
    }
    @objc func closeWindow(_ notification: Notification){
        self.view.window?.close()
    }
    /**
     Notification Handler for log out function - triggered when the toolbar item is pressed.
     */
    @objc func logOut(_ notification: Notification){
        //Order of code execution is important here.
        if(view.window==NSApplication.shared.keyWindow){
            print("segue")
            performSegue(withIdentifier: "logOut", sender: notification)
        }
        self.view.window?.close()
    }
    
    func switchViews(viewID: Int){
        
        self.container.frame = self.container.bounds
        for sView in self.container.subviews {
            sView.removeFromSuperview()
        }
        
        switch viewID{
        case 1:
            self.container.addSubview(dashboard.view)
            dashboard.view.frame = self.container.bounds
        case 2:
            self.container.addSubview(assets.view)
            assets.view.frame = self.container.bounds
        case 3:
            self.container.addSubview(logistics.view)
            logistics.view.frame = self.container.bounds
        case 4:
            self.container.addSubview(jobs.view)
            jobs.view.frame = self.container.bounds
        case 5:
            self.container.addSubview(maintenance.view)
            maintenance.view.frame = self.container.bounds
        case 6:
            self.container.addSubview(people.view)
            people.view.frame = self.container.bounds
        default:
            self.container.addSubview(dashboard.view)
            dashboard.view.frame = self.container.bounds
        }
    }
}
