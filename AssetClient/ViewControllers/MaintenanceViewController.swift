//
//  MaintenanceViewController.swift
//  Production Manager Pro
//
//  Created by James Goodliffe on 01/03/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class MaintenanceViewController: NSViewController {
    
    var windowFuncs = WindowFunctions()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func assetsClicked(_ sender: Any) {
        windowFuncs.showAssets()
    }
    
    @IBAction func jobsClicked(_ sender: Any) {
        windowFuncs.showJobs()
    }
    @IBAction func logisticsClicked(_ sender: Any) {
        windowFuncs.showLogistics()
    }
    @IBAction func maintenanceClicked(_ sender: Any) {
        windowFuncs.showMaintenance()
    }
    @IBAction func peopleClicked(_ sender: Any) {
        windowFuncs.showPeople()
    }
}
